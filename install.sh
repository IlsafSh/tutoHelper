#!/bin/bash

# Устанавливаем переменные
REPO_URL="https://github.com/IlsafSh/tutoHelper"  # URL репозитория
INSTALL_DIR="$HOME/tutoHelper"                    # Директория установки проекта
DIALOG_SCRIPT="$INSTALL_DIR/tutohelper.sh"         # Полный путь к главному скрипту
BIN_DIR="/usr/local/bin"                           # Директория для символической ссылки

# Приветственное сообщение с ASCII-логотипом
logo="
████████╗██╗   ██╗████████╗ ██████╗ ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ 
╚══██╔══╝██║   ██║╚══██╔══╝██╔═══██╗██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗
   ██║   ██║   ██║   ██║   ██║   ██║███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝
   ██║   ██║   ██║   ██║   ██║   ██║██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗
   ██║   ╚██████╔╝   ██║   ╚██████╔╝██║  ██║███████╗███████╗██║     ███████╗██║  ██║
   ╚═╝    ╚═════╝    ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝
"

echo "Добро пожаловать в установку скрипта управления данными студентов!"
echo -E "$logo"

# Функция для установки dialog, если он не установлен
install_dialog() {
  if ! command -v dialog &> /dev/null; then
    echo "dialog не найден, пытаемся установить..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      # Для Linux
      if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y dialog
      elif command -v yum &> /dev/null; then
        sudo yum install -y dialog
      else
        echo "Не удалось определить менеджер пакетов для установки dialog."
        exit 1
      fi
    else
      echo "Неизвестная операционная система."
      exit 1
    fi
  else
    echo "dialog уже установлен."
  fi
}

# Функция для клонирования репозитория
clone_repository() {
  echo "Клонируем репозиторий из GitHub..."
  if [ -d "$INSTALL_DIR" ]; then
    echo "Директория $INSTALL_DIR уже существует. Удаляем её..."
    rm -rf "$INSTALL_DIR"
  fi

  git clone "$REPO_URL" "$INSTALL_DIR"
  if [ $? -ne 0 ]; then
    echo "Не удалось клонировать репозиторий."
    exit 1
  fi

  echo "Проект успешно клонирован в $INSTALL_DIR."
}

# Создаем символическую ссылку
create_symlink() {
  SYMLINK_PATH="$BIN_DIR/tutohelper"
  
  # Проверка существования главного скрипта
  if [ ! -f "$DIALOG_SCRIPT" ]; then
    echo "Ошибка: главный скрипт $DIALOG_SCRIPT не найден."
    exit 1
  fi

  # Удаляем старую ссылку, если она существует
  if [ -L "$SYMLINK_PATH" ] || [ -e "$SYMLINK_PATH" ]; then
    echo "Удаляем старую ссылку $SYMLINK_PATH..."
    sudo rm -f "$SYMLINK_PATH"
  fi

  # Создаем новую ссылку
  echo "Создаём символическую ссылку на $DIALOG_SCRIPT в $SYMLINK_PATH..."
  sudo ln -s "$DIALOG_SCRIPT" "$SYMLINK_PATH"

  # Проверяем успешность создания ссылки
  if [ ! -L "$SYMLINK_PATH" ]; then
    echo "Ошибка: не удалось установить tutohelper в системный путь."
    exit 1
  fi

  echo "Символическая ссылка успешно создана. Теперь вы можете запускать tutohelper из любого места."
}

# Основная логика установки
echo "Запуск установки проекта..."

# Проверка наличия главного скрипта в текущей директории
if [ -f "./tutohelper.sh" ]; then
  echo "Главный скрипт tutoHelper.sh найден в текущей директории."
  INSTALL_DIR="$(pwd)"            # Обновляем INSTALL_DIR на текущую директорию
  DIALOG_SCRIPT="$INSTALL_DIR/tutohelper.sh"  # Обновляем путь к главному скрипту
else
  # Устанавливаем утилиту dialog, если проект не был клонирован
  install_dialog
  # Клонируем проект
  clone_repository
fi

# Создаем символическую ссылку
create_symlink

# Добавляем проект в системный PATH (если требуется)
# Определяем, какой файл конфигурации использовать в зависимости от оболочки
SHELL_NAME=$(basename "$SHELL")
if [ "$SHELL_NAME" == "bash" ]; then
    RC_FILE="$HOME/.bashrc"
elif [ "$SHELL_NAME" == "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
else
    echo "Неизвестная оболочка $SHELL_NAME. Не удается добавить путь в PATH."
    exit 1
fi

# Проверяем, не добавлен ли уже путь в $PATH
if ! grep -q "$INSTALL_DIR" "$RC_FILE"; then
    echo "Добавляю директорию проекта в PATH в $RC_FILE..."
    echo "export PATH=\"\$PATH:$PROJECT_DIR\"" >> "$RC_FILE"
else
    echo "Директория проекта уже добавлена в PATH."
fi

# Уведомление об успешной установке
echo "Установка завершена! Вы можете использовать tutoHelper из любого места в терминале."
echo "Просто введите 'tutohelper' для запуска."

exit 0
