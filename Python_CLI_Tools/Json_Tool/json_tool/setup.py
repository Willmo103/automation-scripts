from setuptools import setup, find_packages

setup(
    name="json_tool",
    version="0.0.1",
    description="A CLI for parsing and editing json files",
    packages=find_packages(),
    install_requires=[
        "click"
    ],
    entry_points="""
    [console_scripts]
    json=json_tool:json_tool
    """
)
