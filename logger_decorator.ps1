$test = Test-Path "./utils"
if (!$test) {
    Write-Output "Utils does not exsist, creating ./utils"
    New-Item "./" -ItemType "directory" -Name "utils"
}

Write-Output 'import os, time
from datetime import datetime


def log(logfile: str = "./log.txt"):
    def log_inner(func):
        def wrapper(*args, **kwargs):
            log_file: str = logfile
            log_out: str = "*****"
            log_out += f"\nFunction: { func.__name__ } ran at: {datetime.now()}"
            log_out += f"\nargs: { args }, kwargs:, { kwargs }"
            start: float = time.time()
            result = func(*args, **kwargs)
            finished: float = time.time()
            log_out += f"\nReturned value: { result }"
            log_out += f"\nFinished at: {datetime.now()}"
            log_out += f"\nStart time: {start}\nEnd time: {finished}"
            if (finished - start) / 60 > 1:
                log_out += f"""\nFinished in: {str((finished - start)/ 60).split(".")[0]} minute(s), {(finished - start ) % 60} seconds.\n"""
            else:
                log_out += f"\nFinished in: {(finished - start ) % 60} seconds\n"
            if os.path.exists(log_file):
                with open(log_file, "a") as f:
                    f.write(log_out)
            else:
                with open(log_file, "w") as f:
                    f.write(log_out)
            return result
        return wrapper
    return log_inner
' > utils/logger.py
