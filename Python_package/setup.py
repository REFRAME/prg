
from setuptools import setup, find_packages
from codecs import open
from os import path

# try:
#     from pypandoc import convert
#     read_md = lambda f: convert(f, 'rst')
# except ImportError:
#     print("warning: pypandoc module not found, could not convert Markdown to RST")
#     read_md = lambda f: open(f, 'r').read()

with open('README.rst') as file:
    long_description = file.read()


setup(
    name='pyprg',
    version='0.1.1b2',
    description='Creates the Precision-Recall-Gain curve and calculates the area under the curve',
#    long_description=read_md('README.md'),
    long_description=long_description,
    url='https://github.com/meeliskull/prg',
    author='Meelis Kull, Peter Flach, Telmo de Menezes e Silva Filho, Miquel Perello Nieto',
    author_email='meelis.kull@gmail.com',
    license='MIT + file LICENSE',
    # See https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        'Development Status :: 4 - Beta',
	'Environment :: Console',
	'Intended Audience :: Science/Research',
	'License :: OSI Approved :: MIT License',
	'Operating System :: OS Independent',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
	'Topic :: Scientific/Engineering',
    ],
    keywords='classifier evaluation precision recall gain',
    packages=['prg'],
    install_requires=['numpy','matplotlib'],
)

