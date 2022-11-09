import click

# This is just a placeholder for the second tool I'll be building with Click
@click.command()
def scratch_file():
    print("you've called the Scratch File CLI Tool!!!")

    # create a check for a file
        # if theirs not a file location prompt the user to add a new scratch file from scratch
    # use options to:
        # List the keys from the json scratch file, and give the user an option to select which file they want to read from
        # edit any of the entries they have in the scratch file,
        # Create a new file,
        # add to or delete a file
