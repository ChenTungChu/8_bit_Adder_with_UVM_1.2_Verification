# clean_uvm_log_align.py
import re

# 檔案設定
input_file = "raw_data.txt"
output_file = "result.txt"

# 最大時間值，用於對齊（例如 205001）
MAX_TIME = 205001
# 根據最大值計算欄寬
TIME_WIDTH = len(str(MAX_TIME))

# 正則表示式：
# .*@(\s*\d+):[^\[]*(\[.*)
# group(1) → 時間數字部分
# group(2) → 從 [ 開始的內容
pattern = re.compile(r".*@\s*(\d+):[^\[]*(\[.*)")

with open(input_file, "r", encoding="utf-8") as fin, open(output_file, "w", encoding="utf-8") as fout:
    for line in fin:
        line = line.strip()
        m = pattern.match(line)
        if m:
            time_str = m.group(1)
            msg = m.group(2)
            # 對齊格式化：@ 後時間靠右對齊
            formatted = f"@ {time_str.rjust(TIME_WIDTH)}: {msg}"
            fout.write(formatted + "\n")
        else:
            # 若非匹配行，可選擇保留或略過
            fout.write(line + "\n")

print(f"Finished processing! Output has been exported to: {output_file}")
