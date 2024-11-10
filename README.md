
# An Approximate and Iterative Posit Multiplier


| Name                    | Roll Number  |
|-------------------------|--------------|
| Saketh Jooluri           | IMT2022528   |
| Sai Swaraj Pachipala     | IMT2022581   |
| Likithkumar Rachaputi    | MT2024528    |

## Introduction:
Posit number system is an emerging number system which aims to be a competitor to the existing IEEE floating-point number system
![image](https://github.com/user-attachments/assets/2f0a04c3-1d52-41cc-a07a-0533e8bbc88c)

$$
\text{value} = (-1)^s \times (\text{useed})^k \times 2^{\text{exp}} \times \left(1 + \text{frac}\right)
$$

Where:

$$
\text{useed} = (2^{\text{es}})^k
$$


## Methodology: 
1)	First, we extracted the sign, regime, exponent, and mantissa bits from the given 32-bit numbers. This step is referred to as decoding.
2)	The decoding process was performed for both numbers that we need to multiply.
3)	Using the sign, regime, and exponent of the two numbers, we calculated the sign, regime, and exponent of the result based on the **[reference paper](https://ieeexplore.ieee.org/document/9401158)**.
4)	Using the mantissas of the two numbers, we computed the mantissa of the result using an iterative approach, as described in the **[reference paper](https://ieeexplore.ieee.org/document/9401158)**.
5)	Finally, using the result’s sign, regime, and exponent (from step 3) and the mantissa (from step 4), we reconstructed the final result. This step is called encoding.
   
![Screenshot 2024-11-10 114445](https://github.com/user-attachments/assets/d7a4335e-8799-4bf1-9378-ee78aa3bf8f8)

Once we implemented the design in Verilog, we successfully simulated and verified the results. However, during synthesis, we encountered the following issues:
1.	Non-synthesizable loop variables: To resolve this, we replaced the loop variable with its maximum value and used a conditional if statement within the loop to eliminate the error.
2.	Unsupported break statement in Verilog: Since the break statement is not supported in Verilog, we replaced it with i = -1; which causes the loop to exit as intended.
   
![WhatsApp Image 2024-11-08 at 21 01 41_fa7f6cc8](https://github.com/user-attachments/assets/33edb41b-fdf3-4f3f-adc2-2d3668850cce)
![Screenshot 2024-11-08 144308](https://github.com/user-attachments/assets/f8c28845-18de-4026-80ae-afa93992bf88)


![Screenshot 2024-11-08 150632](https://github.com/user-attachments/assets/17b2dd91-7f3f-416d-af8c-f9a728d49685)


## Results:
### 1. Max Clock Frequency Achieved:
![Screenshot 2024-11-08 155240](https://github.com/user-attachments/assets/b592fa90-9870-41fd-9e71-f26b312bb3cb)
![Screenshot 2024-11-08 155321](https://github.com/user-attachments/assets/8abf1d6c-1a96-41c5-80a9-e4ed6bda0952)

  $$
  \text{Max Freq} = \frac{1}{T_{\text{clk}} - W_{\text{NS}}} = \frac{1}{(4.5 - 0.13) \, \text{ns}} = 228.23  \text{MHz}
  $$


### 2. Resource Utilization:
![image](https://github.com/user-attachments/assets/0ba7240e-bc9a-4ae3-9d11-7e5168ef921a)
![image](https://github.com/user-attachments/assets/3bad94e3-96d7-43ae-9d13-ab6312611719)


    
### 3. Latency of Computation:
**Behavioural and Post Implementation simulation Result**
![WhatsApp Image 2024-11-08 at 21 33 44_088bde20](https://github.com/user-attachments/assets/d9288d92-a5f2-4d24-8551-16c6e0c9af3d)

Based on the simulation results, we can conclude that there is no latency present.

    
### 4. Implemented Layout Diagram:
![Screenshot 2024-11-08 151303](https://github.com/user-attachments/assets/2332e741-0f6e-454d-8852-3d335b079bf9)
![Screenshot 2024-11-08 151330](https://github.com/user-attachments/assets/98555af7-230c-49e5-a77c-2fea40e2d1e9)


### 5. Max throughput achievable

$$
\text{Max Throughput} = \frac{1}{T_{\text{clk}} \times \text{Max Utilization Percentage}} = \frac{1}{(4.5 \text{ns} \times 3.8)} \times 100
$$


$$
\text{Max Throughput} = 5.84 \times 10^9 \text{Hz} = 5.84 \text{GHz}
$$

### 6. Error Calculation
Error calculation is performed using a Python program
![Screenshot 2024-11-10 112011](https://github.com/user-attachments/assets/229dfe74-42ed-4693-9203-ddb56cfbbee5)




