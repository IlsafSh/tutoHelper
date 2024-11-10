#!/bin/bash

#trap 'echo "# $BASH_COMMAND";read' DEBUG

# Функция для нахождения студента с максимальным числом правильных ответов
find_best_student() {
  local fs_path=${1}
  local group=${2}
  local group_file="$fs_path/students/groups/$group"
  local tests_folder1="$fs_pathПивоварение/tests"
  local tests_folder2="$fs_pathУфология/tests"
  local result="Лучший студент группы $group:\n"
  declare -A student_ans

  # Проверка, что файл группы существует
  if [ ! -f "$group_file" ]; then
    echo "Файл со списком студентов группы $group не найден"
    return
  fi

  # Проверка, что папка тестов Пивоварения существует
  if [ ! -d "$tests_folder1" ]; then
    echo "Папка с тестами предмета Пивоварение не найдена"
    return
  fi
  
  # Проверка, что папка тестов Уфологии существует
  if [ ! -d "$tests_folder2" ]; then
    echo "Папка с тестами предмета Уфология не найдена"
    return
  fi

  # Поиск всех тестовых файлов
  tests_files=$(find $fs_path/ -type f -path "*/tests/TEST-*")
  
  if [[ "$tests_files" == "" ]]; then
    echo "В папках предметов отсутствуют тесты"
    return
  fi

  # Подсчет общего количества правильных ответов для каждого студента
  for test_file in $tests_files; do
    while IFS=',' read -r year student grp corr_ans score; do
      if [ "$grp" == "$group" ] && [ "$score" -ge 3 ]; then
        student_ans["$student"]=$((student_ans["$student"] + corr_ans))
      fi
    done < "$test_file"
  done

  # Определение студента с максимальным количеством баллов
  local best_student=""
  local max_ans=0
  for student in "${!student_ans[@]}"; do
    if [ "${student_ans[$student]}" -gt "$max_ans" ]; then
      best_student=$student
      max_ans=${student_ans[$student]}
    fi
  done
  
  # Если в result ничего не добавлено, значит студентов в группе нет
  if [[ "$best_student" == "" ]]; then
    result+="Студентов нет в группе"
  else
    result+="$best_student с общим баллом $max_ans"
  fi

  echo -e "$result"
}

find_best_student "$@"
