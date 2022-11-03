$test = Test-Path "./utils"
if (!$test) {
    Write-Output "Utils does not exsist, creating ./utils"
    New-Item "./" -ItemType "directory" -Name "utils"
}

Write-Output 'def log(logfile: str = "./log.txt"):
    """
    A logging decorator. Writes or appends to an exsisting
    log file.

    Output file Schema:
        Function (name of function)
        args: (Tuple of arguments passed) kwargs: (Dict of keyword arguments)
        Returned Value: (results of function)
        Start time: (start time)
        End time: (end time)
        Finished in: ("the time delta)

    @params:logfile: <String> The location and name of the
    logger output file.

    @default: "./log.txt"
    """
    def log_inner(func):
        def wrapper(*args, **kwargs):
            log_file: str = logfile
            log_out: str = "*****"
            log_out += f"\nFunction {func.__name__} ran at: {datetime.now()}"
            log_out += f"\nargs: {args}, kwargs:, {kwargs}"
            start =  datetime.now()
            result = func(*args, **kwargs)
            finished =  datetime.now()
            log_out += f"\nReturned value: {result}"
            log_out += f"\nStart time: {start}\nEnd time: {finished}"
            log_out += f"\nFinished in: {finished - start}\n"
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
