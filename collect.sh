#!/bin/bash
# Сбор замеров для отчёта. Запуск из папки с main.c и Makefile:  bash collect.sh
# Результат: results.csv (n,threads,seq_ms,par_ms,speedup,efficiency) и cpu_info.txt
cd "$(dirname "$0")" || exit 1
make -s || { echo "make failed"; exit 1; }

CORES=$(nproc)
SIZES=${SIZES:-"65536 1048576 4194304 16777216"}
THREADS=$(echo 1 2 3 4 "$CORES" 16 128 1024 | tr ' ' '\n' | sort -nu | tr '\n' ' ')

{ lscpu | grep -E "Model name|^CPU\(s\)|Thread\(s\) per core"; echo "nproc=$CORES"; uname -r; } > cpu_info.txt

echo "n,threads,seq_ms,par_ms,speedup,efficiency" > results.csv
for N in $SIZES; do
  for T in $THREADS; do
    echo "N=$N threads=$T ..." >&2
    line=$(./lab2 "$N" "$T" | grep '^threads=')
    if [ -z "$line" ]; then echo "  ошибка запуска, пропуск" >&2; continue; fi
    echo "$line" | sed -E 's/[a-z_]+=//g' | awk -v n="$N" '{print n","$1","$2","$3","$4","$5}' >> results.csv
  done
done
echo "Готово. Файлы: results.csv, cpu_info.txt" >&2
cat results.csv
