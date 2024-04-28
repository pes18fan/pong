set shell := ["cmd.exe", "/c"]

default: run

build:
	odin build pong/ -out:pong.exe -debug

run: build
    pong.exe 
