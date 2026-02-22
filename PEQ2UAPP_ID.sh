#!/usr/bin/bash

# Buat TBEQPresets folder
OUT_DIR="$(pwd)/TBEQPresets"
mkdir -p "$OUT_DIR"
clear

# Banner
echo "📊 ParametricEQ → ToneBoosters 📊"
  sleep 3
    clear
  echo "ℹ️ ParametricEQ → UAPP 10-Band PEQ ℹ️"
    sleep 1
  echo "⚠️ Supported PEQ ⚠️
✅ AutoEq PEQ (autoeq.app)
✅ SQUIGLINK (squig.link)
✅ Crinacle Graph Tool (graph.hangout.audio)
✅ Listener's EQ Playground (listener800.github.io)"
  sleep 3
clear

# Mulai 
echo "🔄 ParametricEQ → ToneBoosters 🔄"
sleep 3

# Ambil semua file .txt
for file in *.txt; do
  if [ ! -f "$file" ]; then
    echo "⛔ File ParametricEQ tidak ditemukan!"
    break
  fi
  echo "ℹ️ Memproses: $file"
    sleep 1
  mapfile -t lines < "$file"

  if [[ ! ${lines[0]} == Preamp* ]]; then
    echo "⛔ Bukan ParametricEQ: $file"
    break
  fi

  # Nama preset
  preset="$(basename "$file" .txt)"

  # Hapus trailing zero
  trim_float() {
    awk -v n="$1" 'BEGIN {
      s = sprintf("%.6f", n)
      sub(/\.?0+$/, "", s)
      print s
    }'
  }

  # Preamp
  preamp_raw=$(echo "${lines[0]}" | awk '{print $2}')

  # Kalkulasi Preamp
  preamp_norm=$(awk -v p="$preamp_raw" 'BEGIN{print (p+20)/40}')
  preamp=$(trim_float "$preamp_norm")
  echo "ℹ️ Preamp: $preamp_raw dB → $preamp"
    sleep 0.1
  # Filter 1-10
  lines=("${lines[@]:1}")

  # Default value
  for i in {0..9}; do
    FREQ[$i]="0.9282573"
    GAIN[$i]="0.5"
    ON[$i]=0
    Q[$i]="0.39434525"
  done

  # Cek filter on/off
  idx=0
  for line in "${lines[@]}"; do
    temp="${line#*: }"
    if [[ $temp != ON* ]]; then
      ((idx++))
      continue
    fi

    # Parser filter
    f=$(echo "$temp" | sed -n 's/.*Fc \([0-9]*\) Hz.*/\1/p')
    g=$(echo "$temp" | sed -n 's/.*Gain \([-0-9.]*\) dB.*/\1/p')
    q=$(echo "$temp" | sed -n 's/.*Q \([0-9.]*\).*/\1/p')

    # Kalkulasi Frequency 
    f_norm=$(awk -v f="$f" 'BEGIN{printf "%.8f", ((f-16)/(20000-16))^(1/3)}')
    echo "ℹ️ Frequency: $f Hz → $f_norm"
      sleep 0.1

    # Kalkulasi Gain
    g_norm=$(awk -v g="$g" 'BEGIN{print (g+20)/40}')
    echo "ℹ️ Gain: $g dB → $g_norm"
      sleep 0.1

    # Kalkulasi Q
    q_norm=$(awk -v q="$q" 'BEGIN{printf "%.8f", ((q-0.1)/(10-0.1))^(1/3)}')
    echo "ℹ️ Q: $q → $q_norm"
      sleep 0.1

    # Value untuk XML
    FREQ[$idx]="$f_norm"
    GAIN[$idx]="$(trim_float "$g_norm")"
    Q[$idx]="$q_norm"
    ON[$idx]=1

    ((idx++))
  done

  # Output XML
  out="$OUT_DIR/$preset.xml"

  {
    # Header metadata
    echo '<?xml version="1.0" encoding="ISO-8859-1"?>'
    echo "<Preset>"
    echo "<PresetInfo Name=\"$preset\" TenBand=\"1\">"

    # Filter 1-10
    for i in {0..9}; do
      echo "<Value>${FREQ[$i]}</Value>"
      echo "<Value>${GAIN[$i]}</Value>"
      echo "<Value>${ON[$i]}</Value>"
      echo "<Value>${Q[$i]}</Value>"
      echo "<Value>0.21428572</Value>"
      echo "<Value>0</Value>"
    done

    # Preamp
    echo "<Value>0</Value>"
    echo "<Value>$preamp</Value>"
    echo "<Value>1</Value>"
    echo "<Value>0.33333334</Value>"
    echo "<Value>0.05</Value>"
    echo "<Value>0</Value>"
    echo "</PresetInfo>"
    echo "</Preset>"
  } > "$out"
 echo "✅ $preset.xml"
done

# Selesai
sleep 1
  echo "📊 ParametricEQ → ToneBoosters 📊"
sleep 3

# Credits
echo "©️ KProject ©️
GitHub: @Fearmipan
Telegram: @KProjectX"
