import itertools

def regime(n, num_array):
    count = 0
    for i in range (1, n-1, 1):
        if(num_array[i] == num_array[i+1]):
            count = count + 1
        else:
            break
    count = count + 1

    if num_array[1] == 0:
        k = -count
    else:
        k = count - 1
    #print(k, count)
    return k, count 

def exponent(n, es, count, num_array):
    sum = 0
    index = count + 2
    if index >= n:
        return 0
    else:
        for i in range(index, n, 1):
            if es >= 0:
                sum = sum + num_array[i]*(2**(es-1))
                #print(es, i, num_array[i], 2**(es-1), sum)
                es = es -1
            else:
                break
        exp = int(sum)
        return exp

def fraction(n, count, es, num_array):
    index = count + 2 + es
    sum = 0
    if index > n:
        return 1
    else:
        power_index = -1
        for i in range(index, n, 1):
            if n >= index:
                sum =sum + num_array[i] * (2**power_index)
                #print(power_index, 2**power_index, sum)
            else:
                break
            power_index = power_index - 1
    fract = 1 + sum
    return fract


def binary_to_twos_complement(binary_list):
    inverted = [1 - bit for bit in binary_list]
    
    carry = 1
    twos_complement = []
    
    for bit in reversed(inverted):
        if carry == 0:
            twos_complement.append(bit)
            continue
        
        if bit == 0:
            if carry == 1:
                twos_complement.append(1)
                carry = 0
            else:
                twos_complement.append(0)
        else:  
            if carry == 1:
                twos_complement.append(0)
            else:
                twos_complement.append(1)
    

    if carry == 1:
        twos_complement.append(1)

    twos_complement.reverse()

    pos_twos_complement = [1]
    for ele in twos_complement:
        pos_twos_complement.append(ele)

    return pos_twos_complement


def full_adder(a, b, cin):
    sum_bit = a ^ b ^ cin       
    carry_out = (a & b) | (cin & (a ^ b))
    return sum_bit, carry_out

def adder(arr1, arr2):
    result = []
    carry_in = 0    
    for a, b in zip(reversed(arr1), reversed(arr2)):
        sum_bit, carry_out = full_adder(a, b, carry_in)
        result.append(sum_bit)
        carry_in = carry_out 
    return result[::-1]

def mantissa_multiply(n, es, count1, count2, num_array_a, num_array_b):
    index_a = count1 + 1 + es
    index_b = count2 + 1 + es
    k_arr = []
    flag = 1
    LS = 0

    for i in range(index_a, n):
        if num_array_a[i] == 1:
            
            LS = LS + flag
            k_arr.append(flag)
            flag = 0
            
        flag = flag + 1

    arr = num_array_b[index_b:n]
    array_1 = [1] + arr[:-1]
    dup_array = array_1
    i = 0
    n = len(array_1)
    while (i < len(k_arr)):
        k = k_arr[i]
        k = k % n
        array_2 = dup_array[-k:] + dup_array[:-k]
        i = i + 1
        add = adder(array_1, array_2)
        dup_array = array_2
        array_1 = add
    return array_1

def decimal_to_binary_array(decimal):
    if decimal == 0:
        return [0]
    
    binary_array = []
    while decimal > 0:
        binary_array.append(decimal % 2)
        decimal = decimal // 2
    
    return binary_array[::-1]



def encoder(SignO, RgmO, ExpO, mantissa):
    SignO_arr = []
    RgmO_arr = []
    ExpO_arr = []
    posit_result_arr = []
    SignO_arr.append(SignO)

    if RgmO < 0:
        for i in range(0, abs(RgmO)):
            RgmO_arr.append(0)
        RgmO_arr.append(1)
    else:
        for i in range(0, RgmO+1):
            RgmO_arr.append(1)
        RgmO_arr.append(0)

    ExpO_arr = decimal_to_binary_array(ExpO)

    posit_result_arr = SignO_arr + RgmO_arr + ExpO_arr + mantissa
    posit_result_arr = posit_result_arr[0:31]

    print()
    print('Multiplication Result O:')
    for ele in posit_result_arr:
        print(ele, end = ' ')
    print()

    posit_result_arr = posit_result_arr[0:31]
    n_O =len(posit_result_arr)
    es = len(ExpO_arr)

    k_O, count_O = regime(n_O, posit_result_arr)
    fraction_O = fraction(n_O, count_O, ExpO, posit_result_arr)
    

    posit_result = (-1)**posit_result_arr[0] * (2**2**es)**RgmO * (2**ExpO) * (fraction_O)
    #print('posit_result = ',posit_result)
    return posit_result






n_a, es_a = map(int, input("Enter space-separated n and es: ").split())
num_a = input("Enter the number A: ")

if all(bit in '01' for bit in num_a):
    # Store the binary number in an array
    num_array_a = [int(bit) for bit in num_a]
    length_num = len(num_a)
    
    if length_num != n_a:
        print("Invalid input. Please enter a %d valid binary number." % n_a)
        
    else:
        if (num_array_a[0] == 1):
            num_array_a = binary_to_twos_complement(num_array_a[1:])
        
        k_a, count_a = regime(n_a, num_array_a)
        exp_a = exponent(n_a, es_a, count_a, num_array_a)
        fraction_a = fraction(n_a, count_a, es_a, num_array_a)

        print('sign_a =', num_array_a[0])
        print('Rgm_a = ', k_a)
        print('exp_a = ',exp_a)
        print('fraction_a = ', fraction_a)
        posit_a = (-1)**num_array_a[0] * (2**2**es_a)**k_a * (2**exp_a) * (fraction_a)
        print('Posit number_a = ', posit_a)
        print()

else:
    print("Invalid input. Please enter a valid binary number.")




n_b, es_b = map(int, input("Enter space-separated n and es: ").split())
num_b = input("Enter the number B: ")
if all(bit in '01' for bit in num_b):
    # Store the binary number in an array
    num_array_b = [int(bit) for bit in num_b]
    length_num = len(num_b)
    
    if length_num != n_b:
        print("Invalid input. Please enter a %d valid binary number." % n_b)
        
    else:
        if (num_array_b[0] == 1):
            num_array_b = binary_to_twos_complement(num_array_b[1:])
        
        k_b, count_b = regime(n_b, num_array_b)
        exp_b = exponent(n_b, es_b, count_b, num_array_b)
        fraction_b = fraction(n_b, count_b, es_b, num_array_b)

        print('sign_b =', num_array_b[0])
        print('Rgm_b = ', k_b)
        print('exp_b = ',exp_b)
        print('fraction_b = ', fraction_b)
        posit_b = (-1)**num_array_b[0] * (2**2**es_b)**k_b * (2**exp_b) * (fraction_b)
        print('Posit number_b = ', posit_b)
        print()

else:
    print("Invalid input. Please enter a valid binary number.")


RgmO = k_a + k_b
ExpO = exp_a + exp_b
if (ExpO > 8):
    ExpO = ExpO - 8
    RgmO = RgmO + 1
if(num_array_a[0] == num_array_b[0]):
    SignO = 0
else:
    SignO = 1 


print('SignO = ', SignO)
print('RgmO = ', RgmO)
print('ExpO = ', ExpO)

mantissa_multiply = mantissa_multiply(n_a, es_a, count_a+1, count_b+1, num_array_a, num_array_b)
mantissa_multiply = mantissa_multiply[1:]
mantissa_multiply.append(0)


posit_result = encoder(SignO, RgmO, ExpO, mantissa_multiply)
posit_result1 = posit_a * posit_b
posit_result2 = posit_result

print()
print('Posit_Result_1 ',posit_result1)
print('Posit_Result_2 ',posit_result2)

Error = (posit_result1 - posit_result2)/posit_result1
print('Error = ', Error)
