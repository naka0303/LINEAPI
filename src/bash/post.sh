#!/usr/bin/env bash
#
# DATE:   2023-02-24
# UPDATE: 2023-03-12
# PURPOSE:
#   - receive下の価格帯棒グラフ画像を指定されたLINEに送信する
# USAGE:
#   - ./post_jpeg.sh


### 変数宣言 ###
readonly APP_DIR=$(cd $(dirname $0); cd ../../; pwd)
readonly MERCARIAPP_DIR=$(cd $(dirname $0); cd ../../../MercariApp/; pwd)
readonly SCRIPT_NAME=$(basename $0)
readonly LOG_DIR=$(cd $APP_DIR/logs; pwd)
readonly RECEIVE_DIR=$(cd $APP_DIR/receive; pwd)
readonly POSTED_DIR=$(cd $APP_DIR/posted; pwd)
readonly CONF_DIR=$(cd $APP_DIR/config; pwd)
readonly TMP_DIR=$(cd $APP_DIR/tmp; pwd)
readonly SRC_DIR=$(cd $APP_DIR/src; pwd)
readonly YYYYMMDD=$(date '+%Y%m%d')
readonly HHMMSS=$(date '+%H%M%S')
readonly LOG_NAME=${YYYYMMDD}_${SCRIPT_NAME}_log

### 関数宣言 ###
# ログ関数
logger() {
    msg=$1

    now_date=$(date '+%Y-%m-%d %T')
    echo $now_date $msg >> $LOG_DIR/bash/$LOG_NAME.txt
}

# 処理開始用関数
start() {
    script_name=$1
    logger "========== START $script_name =========="
}

# 処理正常終了用関数
normal_end() {
    logger "========== NORMAL END =========="
    exit 0
}

# 処理異常終了用完了
abend() {
    logger "========== ABEND =========="
    exit 1
}

### 処理開始 ###
start $SCRIPT_NAME

### 変数確認 ###
logger "APP_DIR: $APP_DIR"
logger "MERCARIAPP_DIR: $MERCARIAPP_DIR"
logger "SCRIPT_NAME: $SCRIPT_NAME"
logger "RECEIVE_DIR: $RECEIVE_DIR"
logger "POSTED_DIR: $POSTED_DIR"
logger "CONF_DIR: $CONF_DIR"
logger "TMP_DIR: $TMP_DIR"
logger "LOG_DIR: $LOG_DIR"
logger "SRC_DIR: $SRC_DIR"
logger "YYYYMMDD: $YYYYMMDD"
logger "HHMMSS: $HHMMSS"
logger "LOG_NAME: $LOG_NAME"
logger "output_log_file: $LOG_DIR/bash/$LOG_NAME.txt"

# token.txtからLINE APIトークンを取得
readonly api_token=$(sed -n '3p' $CONF_DIR/token.txt)

### 主処理 ###
mkdir -p $POSTED_DIR

# (1) receive下のファイル件数確認
readonly receive_num=$(ls -1 $RECEIVE_DIR | wc -l)
logger "receive_num: $receive_num"
if [ $receive_num -eq 0 ]; then
  normal_end
fi

# (2) receive下のファイル名をテキスト出力 
ls $RECEIVE_DIR/* > $TMP_DIR/receive_jpeg_${YYYYMMDD}_${HHMMSS}.txt

# (3) receive下のファイルをLINEに送信
while read line
do
  graph_filename=$(echo $line)

  logger "[post] $graph_filename"
  curl -X POST -H "Authorization: Bearer $api_token" -F "message=$graph_filename" -F "imageFile=@$graph_filename" https://notify-api.line.me/api/notify
  
  logger "[move] $graph_filename $POSTED_DIR/"
  mv $graph_filename $POSTED_DIR/
done < $TMP_DIR/receive_jpeg_${YYYYMMDD}_${HHMMSS}.txt

# 処理正常終了
normal_end
