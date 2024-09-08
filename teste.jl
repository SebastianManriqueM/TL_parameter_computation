using DataFrames
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
