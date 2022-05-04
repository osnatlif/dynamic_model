import numpy as np
cimport constant_parameters_cy as c


cdef double[:,:] ded_and_ex = np.loadtxt("deductions_exemptions.out")
cdef double[:,:] tax_brackets = np.loadtxt("tax_brackets.out")


cdef class NetIncome_cy:
  def __init__(self):
    self.net_income_s_h = 0
    self.net_income_s_w = 0
    self.net_income_m = 0
    self.net_income_m_unemp = 0

  def __str__(self):
    return "Net Income:\n\tSingle Husband: " + str(self.net_income_s_h) + \
           "\n\tSingle Wife: " + str(self.net_income_s_w) + \
           "\n\tMarried: " + str(self.net_income_m) + \
           "\n\tMarried Unemployed: " + str(self.net_income_m_unemp)


# tax matrix
# -----+--------------------------------------------------------------------------------------------------------------------------------------------------+---------
#      | single                                                                                                                                           | married
# -----+-----------------------------------------+--------------------------------------------------------------------------------------------------------+---------
# year | br1 | br2 | br3 | br4 | br5 | br6 | br7 | br8 | br9 | br10 | br11 | %br1 | %br2 | %br3 | %br4 | %br5 | %br6 | %br7 | %br8 | %br9 | %br10 | %br11 | ...
# -----+--------------------------------------------------------------------------------------------------------------------------------------------------+---------

cdef int TAX_PERCENT_OFFSET = 11

# deduction matrix
# -----+-------------------------------------------------------------+--------------------------------------------+--------------------------------------------+--------
#      |                                                             | 0 kids                                     | 1 kid                                      | 2 kids
# -----+-------------------------------------------------------------+--------------------------------------------+--------------------------------------------+--------
# year | ded married | ded single | ex married | ex single | ex kids | int1% | int1 | int2% | int3% | int2 | int3 | int1% | int1 | int2% | int3% | int2 | int3 | ...
# -----+-------------------------------------------------------------+--------------------------------------------+--------------------------------------------+--------

cdef int DED_OFFSET = 6
cdef int DED_KIDS_OFFSET = 6
cdef int DED_INTERVAL1_OFFSET = DED_OFFSET + 1
cdef int DED_INTERVAL2_OFFSET = DED_OFFSET + 4
cdef int DED_INTERVAL3_OFFSET = DED_OFFSET + 5


cdef double calculate_tax_cy(double reduced_income, int row_number):
  cdef double tax = 0.0
  cdef double lower_bracket
  cdef double upper_bracket
  cdef double percent
  cdef int i
  if reduced_income > 0:
    for i in range(2, 12):
      lower_bracket = tax_brackets[row_number][i-1]
      upper_bracket = tax_brackets[row_number][i]
      percent = tax_brackets[row_number][i-1+TAX_PERCENT_OFFSET]
      if reduced_income <= upper_bracket:
        tax += (reduced_income - lower_bracket)*percent
        break
      tax += (upper_bracket - lower_bracket)*percent

  return tax


cdef double calculate_eict_cy(double wage, int row_number, int kids):
  cdef double EICT = 0.0
  cdef int kids_offset = DED_KIDS_OFFSET*kids
  cdef int offset1 = DED_INTERVAL1_OFFSET+kids_offset
  cdef int offset2 = DED_INTERVAL2_OFFSET+kids_offset
  cdef int offset3 = DED_INTERVAL3_OFFSET+kids_offset
  if wage < ded_and_ex[row_number][offset1]:
    # first interval  credit rate
    EICT = wage*ded_and_ex[row_number][offset1-1]
  elif wage < ded_and_ex[row_number][offset2]:
    # second (flat) interval - max EICT
    EICT = ded_and_ex[row_number][offset2-1]
  elif wage < ded_and_ex[row_number][offset3]:
    EICT = wage*ded_and_ex[row_number][offset3-2]

  return EICT

# similar handling for husband and wife in case of singles
cdef double gross_to_net_single_cy(int row_number, int kids, double wage, double exemptions, double deductions):
  cdef double tax = 0.0
  cdef double EICT
  if wage > 0.0:
    reduced_income = wage - deductions - exemptions
    EICT = calculate_eict_cy(wage, row_number, kids)
    if EICT == 0.0:
      tax = calculate_tax_cy(reduced_income, row_number)
    return wage - tax + EICT

  return 0.0


cdef double gross_to_net_married_cy(int row_number, int kids, double wage_h, double wage_w, double exemptions, double deductions):
  cdef double tax = 0.0
  cdef double EICT
  cdef double reduced_income
  cdef double tot_income
  if wage_h > 0.0:
    reduced_income = wage_h + wage_w - deductions - exemptions
    tot_income = wage_h + wage_w
    EICT = calculate_eict_cy(tot_income, row_number, kids)
    if EICT == 0.0:
      tax = calculate_tax_cy(reduced_income, row_number)
    return tot_income - tax + EICT

  return 0.0


cdef NetIncome_cy gross_to_net_cy(int kids, double wage_w, double wage_h, int t, int age_index):
  # the tax brackets and the deductions and exemptions starts at 1980 and
  # ends at 2035. most of the sample turn 18 at 1980 (NLSY79)
  cdef int row_number = t + age_index           # row number on matrix 1980-2035.

  cdef double deductions_m = ded_and_ex[row_number][1]
  cdef double deductions_s = ded_and_ex[row_number][2]
  cdef double exemptions_m = ded_and_ex[row_number][3] + ded_and_ex[row_number][5] * kids
  cdef double exemptions_s_w = ded_and_ex[row_number][4] + ded_and_ex[row_number][5] * kids
  cdef double exemptions_s_h = ded_and_ex[row_number][4]

  cdef NetIncome_cy result = NetIncome_cy()

  # CALCULATE NET INCOME FOR SINGLE WOMEN
  result.net_income_s_w = gross_to_net_single_cy(row_number, kids, wage_w, exemptions_s_w, deductions_s)

  # CALCULATE NET INCOME FOR SINGLE MEN
  result.net_income_s_h = gross_to_net_single_cy(row_number, c.NO_KIDS, wage_h, exemptions_s_h, deductions_s)

  # CALCULATE NET INCOME FOR MARRIED COUPLE
  result.net_income_m = gross_to_net_married_cy(row_number, kids, wage_h, wage_w, exemptions_m, deductions_m)
  result.net_income_m_unemp = gross_to_net_married_cy(row_number, kids, wage_h, 0, exemptions_m, deductions_m)

  return result
