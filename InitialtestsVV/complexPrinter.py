# Function to take a string of numbers and sort them
def sort_numbers_string(numbers_string):
    # Split the string into a list of numbers
    numbers_list = numbers_string.split()
    # Convert each number to an integer
    numbers_list = [int(num) for num in numbers_list]
    # Sort the list of numbers
    sorted_numbers = sorted(numbers_list)
    # Convert the sorted numbers back to a string
    return ' '.join(str(num) for num in sorted_numbers)

# Sample string execution
sample_string = "5 2 8 1 9 3"
print("Original string:", sample_string)
sorted_string = sort_numbers_string(sample_string)
print("Sorted string:", sorted_string)
import random

def jumble_sorted_numbers(sorted_string):
    # Split the sorted string into a list of numbers
    sorted_list = sorted_string.split()
    # Shuffle the list of numbers
    random.shuffle(sorted_list)
    # Convert the jumbled list back to a string
    return ' '.join(sorted_list)

# Example usage of the jumble function
jumbled_string = jumble_sorted_numbers(sorted_string)
print("Jumbled string:", jumbled_string)
