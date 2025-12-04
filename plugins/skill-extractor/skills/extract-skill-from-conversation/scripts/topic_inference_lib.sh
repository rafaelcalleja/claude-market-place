#!/bin/bash
# topic_inference_lib.sh - Biblioteca de funciones reutilizables para inferencia de topics
# Uso: source topic_inference_lib.sh

# =============================================================================
# CONFIGURACIÓN
# =============================================================================

DEFAULT_MODEL="${FABRIC_MODEL:-claude-3-5-haiku-latest}"

# =============================================================================
# FUNCIONES BASE (Shared Components)
# =============================================================================

extract_user_messages() {
    local jsonl_file="$1"
    jq -r 'select(.type == "user") | .message.content // ""' "$jsonl_file" 2>/dev/null
}

extract_full_conversation() {
    local jsonl_file="$1"
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$script_dir/parse_conversation.sh" "$jsonl_file" 2>/dev/null
}

check_fabric() {
    if ! command -v fabric &> /dev/null; then
        echo "Warning: fabric not available" >&2
        return 1
    fi
    return 0
}

run_fabric_pattern() {
    local pattern="$1"
    local model="${2:-$DEFAULT_MODEL}"
    local input_file="${3:-/dev/stdin}"

    if ! check_fabric; then
        echo "FABRIC_NOT_AVAILABLE"
        return 1
    fi

    # Usar -o con archivo único, eliminarlo antes porque mktemp lo crea vacío
    local output_file=$(mktemp --suffix=.fabric.out)
    rm -f "$output_file"  # Fabric no sobrescribe, debe no existir
    trap "rm -f $output_file" RETURN

    if [[ "$input_file" == "/dev/stdin" ]]; then
        fabric -p "$pattern" -m "$model" -o "$output_file" >/dev/null 2>&1
    else
        cat "$input_file" | fabric -p "$pattern" -m "$model" -o "$output_file" >/dev/null 2>&1
    fi

    # Leer resultado del archivo (limpio, sin errores de providers)
    if [[ -f "$output_file" && -s "$output_file" ]]; then
        cat "$output_file"
    else
        echo "ERROR_RUNNING_PATTERN"
    fi
}

# =============================================================================
# ATOMIC PATTERN FUNCTIONS (Reusable Pattern Calls)
# =============================================================================

# Extrae el mensaje core (1 frase)
pattern_core_message() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "extract_core_message" "$model" "$input_file"
}

# Genera tags (palabras clave)
pattern_tags() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "create_tags" "$model" "$input_file"
}

# Extrae la idea principal con recomendación
pattern_main_idea() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "extract_main_idea" "$model" "$input_file"
}

# Extrae el problema primario
pattern_primary_problem() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "extract_primary_problem" "$model" "$input_file"
}

# Extrae la solución primaria
pattern_primary_solution() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "extract_primary_solution" "$model" "$input_file"
}

# Crea resumen de 5 niveles
pattern_5_levels() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "create_5_sentence_summary" "$model" "$input_file"
}

# Extrae insights novedosos (alpha)
pattern_alpha() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "extract_alpha" "$model" "$input_file"
}

# Extrae patrones reutilizables
pattern_patterns() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "extract_patterns" "$model" "$input_file"
}

# Extrae actividades principales
pattern_activities() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "extract_main_activities" "$model" "$input_file"
}

# Crea capítulos/segmentos
pattern_chapters() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "create_video_chapters" "$model" "$input_file"
}

# Aplica tags estandarizados
pattern_standard_tags() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "apply_ul_tags" "$model" "$input_file"
}

# Resumir
pattern_summarize() {
    local input_file="$1"
    local model="${2:-$DEFAULT_MODEL}"
    run_fabric_pattern "summarize" "$model" "$input_file"
}

# =============================================================================
# APPROACH FUNCTIONS (Composable Strategies)
# =============================================================================

approach_ultra_concise() {
    local user_messages_file="$1"
    local model="${2:-$DEFAULT_MODEL}"

    echo "=== Approach 1: Ultra-Concise ===" >&2

    # Cargar el prompt mejorado
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local prompt_file="$script_dir/../prompts/ultra_concise.txt"

    if [[ ! -f "$prompt_file" ]]; then
        echo '{"error": "Prompt file not found"}' >&2
        return 1
    fi

    # Crear archivo temporal con prompt + user messages
    local temp_input=$(mktemp)
    trap "rm -f $temp_input" RETURN

    cat "$prompt_file" > "$temp_input"
    echo "" >> "$temp_input"
    echo "## User Messages:" >> "$temp_input"
    echo "" >> "$temp_input"
    cat "$user_messages_file" >> "$temp_input"

    # Ejecutar con raw_query y devolver resultado tal cual
    local output_file=$(mktemp --suffix=.fabric.out)
    rm -f "$output_file"
    trap "rm -f $output_file $temp_input" RETURN

    cat "$temp_input" | fabric -p raw_query -m "$model" -o "$output_file" >/dev/null 2>&1

    # Extraer JSON del output (puede tener texto antes/después)
    if [[ -f "$output_file" && -s "$output_file" ]]; then
        # Usar sed para extraer desde primera { hasta última }
        sed -n '/^{/,/^}/p' "$output_file"
    else
        echo '{"error": "No output generated"}'
    fi
}

approach_progressive_levels() {
    local user_messages_file="$1"
    local model="${2:-$DEFAULT_MODEL}"

    echo "=== Approach 2: Progressive Levels ===" >&2

    local levels=$(pattern_5_levels "$user_messages_file" "$model")

    jq -n \
        --arg levels "$levels" \
        '{
            approach: "progressive_levels",
            summary_levels: $levels
        }'
}

approach_insight_extraction() {
    local user_messages_file="$1"
    local model="${2:-$DEFAULT_MODEL}"

    echo "=== Approach 3: Insight Extraction ===" >&2

    local main_idea=$(pattern_main_idea "$user_messages_file" "$model")
    local alpha=$(pattern_alpha "$user_messages_file" "$model")

    jq -n \
        --arg main_idea "$main_idea" \
        --arg alpha "$alpha" \
        '{
            approach: "insight_extraction",
            main_idea: $main_idea,
            novel_insights: $alpha
        }'
}

approach_pattern_recognition() {
    local conversation_file="$1"
    local model="${2:-$DEFAULT_MODEL}"

    echo "=== Approach 4: Pattern Recognition ===" >&2

    local patterns=$(pattern_patterns "$conversation_file" "$model")
    local activities=$(pattern_activities "$conversation_file" "$model")

    jq -n \
        --arg patterns "$patterns" \
        --arg activities "$activities" \
        '{
            approach: "pattern_recognition",
            patterns: $patterns,
            main_activities: $activities
        }'
}

approach_temporal_segmentation() {
    local conversation_file="$1"
    local model="${2:-$DEFAULT_MODEL}"

    echo "=== Approach 5: Temporal Segmentation ===" >&2

    local chapters=$(pattern_chapters "$conversation_file" "$model")

    jq -n \
        --arg chapters "$chapters" \
        '{
            approach: "temporal_segmentation",
            chapters: $chapters
        }'
}

approach_tags_categorization() {
    local user_messages_file="$1"
    local model="${2:-$DEFAULT_MODEL}"

    echo "=== Approach 6: Tags + Categorization ===" >&2

    local tags=$(pattern_tags "$user_messages_file" "$model")
    local categories=$(pattern_standard_tags "$user_messages_file" "$model")

    jq -n \
        --arg tags "$tags" \
        --arg categories "$categories" \
        '{
            approach: "tags_categorization",
            tags: $tags,
            categories: $categories
        }'
}

approach_hybrid() {
    local user_messages_file="$1"
    local model="${2:-$DEFAULT_MODEL}"

    echo "=== Approach 7: Hybrid (Parallel) ===" >&2

    # Crear archivos temporales para resultados
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    # Ejecutar patterns en paralelo
    pattern_core_message "$user_messages_file" "$model" > "$temp_dir/core.txt" &
    local pid_core=$!

    pattern_tags "$user_messages_file" "$model" > "$temp_dir/tags.txt" &
    local pid_tags=$!

    pattern_main_idea "$user_messages_file" "$model" > "$temp_dir/idea.txt" &
    local pid_idea=$!

    # Esperar a que terminen
    wait $pid_core $pid_tags $pid_idea

    # Leer resultados
    local core=$(cat "$temp_dir/core.txt")
    local tags=$(cat "$temp_dir/tags.txt")
    local idea=$(cat "$temp_dir/idea.txt")

    jq -n \
        --arg core "$core" \
        --arg tags "$tags" \
        --arg idea "$idea" \
        '{
            approach: "hybrid",
            core_message: $core,
            tags: ($tags | split(", ")),
            main_idea: $idea,
            suggested_name: ($core | ascii_downcase | gsub("[^a-z0-9]+"; "-") | gsub("^-|-$"; ""))
        }'
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

list_approaches() {
    cat <<EOF
Available Approaches:
1. ultra-concise       - Fast, minimal (core + tags)
2. progressive-levels  - 5-level summary hierarchy
3. insight-extraction  - Focus on value and insights
4. pattern-recognition - Identify reusable workflows
5. temporal-segmentation - Detect topic changes over time
6. tags-categorization - Searchable tags and categories
7. hybrid              - Recommended: parallel combination

Usage:
  run_approach <approach> <input_file> [model]
EOF
}

run_approach() {
    local approach="$1"
    local input_file="$2"
    local model="${3:-$DEFAULT_MODEL}"

    # Preparar archivos de entrada según el approach
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    local user_messages="$temp_dir/user_messages.txt"
    local conversation="$temp_dir/conversation.txt"

    # Extraer user messages (común para muchos approaches)
    if [[ "$input_file" == *.jsonl ]]; then
        extract_user_messages "$input_file" > "$user_messages"
        extract_full_conversation "$input_file" > "$conversation"
    else
        # Si ya es texto, asumimos que son user messages
        cat "$input_file" > "$user_messages"
        cat "$input_file" > "$conversation"
    fi

    # Ejecutar el approach seleccionado
    case "$approach" in
        "1"|"ultra-concise")
            approach_ultra_concise "$user_messages" "$model"
            ;;
        "2"|"progressive-levels")
            approach_progressive_levels "$user_messages" "$model"
            ;;
        "3"|"insight-extraction")
            approach_insight_extraction "$user_messages" "$model"
            ;;
        "4"|"pattern-recognition")
            approach_pattern_recognition "$conversation" "$model"
            ;;
        "5"|"temporal-segmentation")
            approach_temporal_segmentation "$conversation" "$model"
            ;;
        "6"|"tags-categorization")
            approach_tags_categorization "$user_messages" "$model"
            ;;
        "7"|"hybrid")
            approach_hybrid "$user_messages" "$model"
            ;;
        *)
            echo "Error: Unknown approach '$approach'" >&2
            list_approaches >&2
            return 1
            ;;
    esac
}
