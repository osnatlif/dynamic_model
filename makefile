.PHONY: all clean test

all:
	python setup.py build_ext --inplace

test: all
	python -m unittest -v test_married_couple
	python -m unittest -v test_calculate_emax

clean:
	python setup.py clean --all
	rm -rf *.c
	rm -rf *.so
