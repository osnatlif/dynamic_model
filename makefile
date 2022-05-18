.PHONY: all clean test deps

all:
	python setup.py build_ext --inplace

test: all
	python -m unittest -v test_married_couple
	python -m unittest -v test_calculate_emax

deps:
	pip install -r requirements.txt

clean:
	python setup.py clean --all
	rm -rf *.c
	rm -rf *.so
