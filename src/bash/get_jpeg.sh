#!/usr/bin/env bash
#
# DATE:   2023-02-24
# UPDATE: 2023-03-12
# PURPOSE:
#   - MercariAppで作成された価格帯棒グラフ画像(jpeg)を取得する
# USAGE:
#   - ./get_jpeg.sh


### 変数宣言 ###
readonly APP_DIR=$(cd $(dirname $0); cd ../../; pwd)
readonly MERCARIAPP_DIR=$(cd $(dirname $0); cd ../../../MercariApp/; pwd)
readonly SCRIPT_NAME=$(basename $0)
readonly LOG_DIR=$(cd $APP_DIR/logs; pwd)
readonly RECEIVE_DIR=$(cd $APP_DIR/receive; pwd)
readonly POSTED_DIR=$(cd $APP_DIR/posted; pwd)
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

# 処理異常終了用関数
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
logger "SCRIPT_NAME: $SCRIPT_NAME"
logger "LOG_DIR: $LOG_DIR"
logger "SRC_DIR: $SRC_DIR"
logger "YYYYMMDD: $YYYYMMDD"
logger "HHMMSS: $HHMMSS"
logger "LOG_NAME: $LOG_NAME"
logger "output_log_file: $LOG_DIR/bash/$LOG_NAME.txt"

### 主処理 ###
# (1) MercariApp1/graphと、LINEAPI/postedを比較し、差分ファイル名をテキスト出力
logger "[diff] $MERCARIAPP_DIR/graph $POSTED_DIR > $TMP_DIR/get_jpeg_${YYYYMMDD}_${HHMMSS}.txt"
diff -qr $MERCARIAPP_DIR/graph $POSTED_DIR > $TMP_DIR/get_jpeg_${YYYYMMDD}_${HHMMSS}.txt

# (2) 差分ファイルがあるか確認
diff_num=$(cat $TMP_DIR/get_jpeg_${YYYYMMDD}_${HHMMSS}.txt | wc -l)
logger "diff_num: $diff_num"
if [ $diff_num -eq 0 ]; then
  rm -rf $TMP_DIR/*
  normal_end
fi

# (3) (1)で出力されたファイルをLINEAPI/receiveにコピー
while read line
do
  graph_filename=$(echo $line | sed -e s/^[^:]*:// | sed -e 's/ //g')

  logger "[copy] $MERCARIAPP_DIR/graph/$graph_filename $RECEIVE_DIR"
  cp $MERCARIAPP_DIR/graph/$graph_filename $RECEIVE_DIR
done < $TMP_DIR/get_jpeg_${YYYYMMDD}_${HHMMSS}.txt

# (3) tmp下のファイルを全て削除
rm -rf $TMP_DIR/*

# 処理正常終了
normal_end
