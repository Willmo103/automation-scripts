from setuptools import setup, find_packages

setup(
    name="scratch_file",
    version="0.0.1",
    description="A CLI for saving code snippets to a retrievable list",
    packages=find_packages(),
    install_requires=[
        "click"
    ],
    entry_points="""
    [console_scripts]
    scratch=scratch_file:scratch_file
    """
)
