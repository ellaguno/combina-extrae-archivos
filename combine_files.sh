#!/bin/bash

# Proyecto: Content Processor
# Script: Combinador de archivos con árbol de directorios
# Autor: Eduardo Llaguno
# Fecha: 2024-09-20

# Habilitar el modo de depuración
set -x

# Obtener la fecha actual (sin hora)
current_date=$(date +"%Y-%m-%d")

# Nombre del archivo de salida
output_file="combined_files_${current_date}.txt"
search_path="."
exclude_patterns=()
project_name=""

# Mostrar ayuda
usage() {
    echo "Usage: $0 [-n project_name] [-p path] [-x exclude_pattern1] [-x exclude_pattern2] [...]"
    echo "  -n project_name    Specify the project name (optional, defaults to the directory name)"
    echo "  -p path            Specify the directory to search files in (default: current directory)"
    echo "  -x exclude_pattern Specify additional patterns to exclude files or directories (can be used multiple times)"
    echo
    echo "Note: Binary files, images (including SVG), and some common file types are excluded by default."
    exit 1
}

# Si no se proporcionan argumentos, mostrar el uso
if [ $# -eq 0 ]; then
    usage
fi

# Procesar opciones de línea de comandos
while getopts "n:p:x:" opt; do
    case $opt in
        n) project_name="$OPTARG" ;;
        p) search_path="$OPTARG" ;;
        x) exclude_patterns+=("$OPTARG") ;;
        *) usage ;;
    esac
done

# Convertir search_path a path absoluto
search_path=$(realpath "$search_path")

# Si no se especificó un nombre de proyecto, usar el nombre del directorio
if [ -z "$project_name" ]; then
    project_name=$(basename "$search_path")
fi

# Limpiar el archivo de salida si ya existe
> "$output_file"

# Escribir encabezado en el archivo de salida
echo "PROYECTO: $project_name" >> "$output_file"
echo "FECHA: $current_date" >> "$output_file"
echo "ARBOL:" >> "$output_file"
echo "=======================" >> "$output_file"

# Patrones de exclusión por defecto (incluyendo binarios, imágenes, SVG y archivos .jar)
default_excludes=("*.exe" "*.bin" "*.o" "*.so" "*.dll" "*.pyc" "*.pyo" "*.jpg" "*.jpeg" "*.png" "*.gif" "*.bmp" "*.tiff" "*.ico" "*.svg" "*.jar")

# Función para verificar si un path debe ser excluido
should_exclude() {
    local path="$1"
    local rel_path="${path#$search_path/}"
    for pattern in "${default_excludes[@]}" "${exclude_patterns[@]}"; do
        if [[ "$rel_path" == $pattern || "$(basename "$path")" == $pattern || "$rel_path" == *"$pattern"* ]]; then
            echo "Excluding: $path (matched pattern: $pattern)" >&2
            return 0
        fi
    done
    return 1
}

# Función para generar el árbol de directorios
generate_tree() {
    local dir="$1"
    local prefix="$2"
    
    local files=()
    local dirs=()
    
    # Leer archivos y directorios, excluyendo los patrones especificados
    while IFS= read -r -d $'\0' entry; do
        if ! should_exclude "$entry"; then
            if [ -d "$entry" ]; then
                dirs+=("$entry")
            else
                files+=("$(basename "$entry")")
            fi
        fi
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -print0 | sort -z)
    
    # Imprimir archivos
    for file in "${files[@]}"; do
        echo "${prefix}├── $file" >> "$output_file"
    done
    
    # Procesar subdirectorios
    local last_dir_index=$((${#dirs[@]} - 1))
    for i in "${!dirs[@]}"; do
        local dir_name=$(basename "${dirs[$i]}")
        if [ $i -eq $last_dir_index ]; then
            echo "${prefix}└── $dir_name" >> "$output_file"
            generate_tree "${dirs[$i]}" "${prefix}    "
        else
            echo "${prefix}├── $dir_name" >> "$output_file"
            generate_tree "${dirs[$i]}" "${prefix}│   "
        fi
    done
}

# Generar el árbol de directorios
generate_tree "$search_path" ""

echo "=======================" >> "$output_file"

# Función para procesar cada archivo
process_file() {
    local file_path="$1"
    
    # Verificar si el archivo está dentro del search_path
    if [[ "$file_path" != "$search_path"/* ]]; then
        echo "Skipping file outside search path: $file_path" >&2
        return
    fi
    
    # Verificar si el archivo debe ser excluido
    if should_exclude "$file_path"; then
        echo "Skipping excluded file: $file_path" >&2
        return
    fi
    
    # Verificar si el archivo es binario
    if file "$file_path" | grep -q "binary"; then
        echo "Skipping binary file: $file_path" >&2
        return
    fi
    
    # Obtener el nombre del archivo y su ruta relativa
    local file_name=$(basename "$file_path")
    local file_dir=$(realpath --relative-to="$search_path" "$(dirname "$file_path")")
    
    echo "Processing file: $file_path" >&2
    
    # Escribir encabezado en el archivo de salida
    echo "File: $file_name" >> "$output_file"
    echo "Path: $file_dir" >> "$output_file"
    echo "----------------------------------------" >> "$output_file"
    
    # Escribir contenido del archivo en el archivo de salida
    cat "$file_path" >> "$output_file"
    echo -e "\n\n" >> "$output_file"
}

export -f process_file
export -f should_exclude
export output_file
export default_excludes
export exclude_patterns
export search_path

# Construir y ejecutar el comando find para procesar archivos
find "$search_path" -type f -print0 | while IFS= read -r -d '' file; do
    process_file "$file"
done

echo "Todos los archivos han sido combinados en $output_file."

# Desactivar el modo de depuración
set +x
