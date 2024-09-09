#=using DataFrames
function filter_dataframe(df::DataFrame, strings::Vector{String})
    # Define the filtering function
    filter_func(row) = any(s -> occursin(strip(lowercase(s)), strip(lowercase(row[1]))), strings)
    println( strings )
    println(df)
    aa = filter(filter_func, df)
    # Apply the filter to the DataFrame
    return aa
end

# Sample DataFrame
df = DataFrame(A = [" Apple pie ", "banana split", "Cherry tart", " Date cake ", "apple_a"], B = [1, 2, 3, 4, 5])

# Vector of strings to match
strings = ["apple"]

# Filter the DataFrame
filtered_df = filter_dataframe(df, strings)

println(filtered_df)




# Define the enumeration type
@enum col_tl_geometry_df begin
    code           = 1
    structure_type = 2
    company        = 3
    state          = 4
    n_circuits     = 5
    n_ground_w     = 6
    voltage_kv     = 7
    Creep_Dist_mm_kv = 8
    Insul_Creep_Dist_mm = 9
    Insul_Spac_mm    = 10
    L_Ins_String_ft  = 11
    xa1_ft           = 12
    xb1_ft           = 13
    xc1_ft           = 14
    ya1_ft           = 15
    yb1_ft           = 16
    yc1_ft           = 17
    # Ground wires
    xa2_ft           = 18
    xb2_ft           = 19
    xc2_ft           = 20
    ya2_ft           = 21
    yb2_ft           = 22
    yc2_ft           = 23
end

# Define a method to convert the enum to an integer
Base.to_index(ix::col_tl_geometry_df) = Int(ix)

# Accessing an enum value
println(Int(code))  # Output: 1=#

@enum Fruit begin
    apple=1 
    orange=2 
    kiwi=3
end
Base.to_index(ix::Fruit) = Int(ix)


function get_price(vector, fruit::Fruit)
    return vector[Int(fruit)]
end


# Create a vector with some values
fruit_prices = [1.5, 2.0, 3.0]

println(get_price(fruit_prices, apple))  # Output: 1.5
println(get_price(fruit_prices, orange)) # Output: 2.0
println(get_price(fruit_prices, kiwi))   # Output: 3.0
