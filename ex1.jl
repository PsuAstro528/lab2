### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 0854551f-fc6d-4c51-bf85-a9c7030e588b
begin
	using BenchmarkTools
	BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1;
end;

# ╔═╡ cb099d3d-5c09-4c56-9c59-83adab60f651
using LinearAlgebra

# ╔═╡ a1122848-347f-408b-99c2-a7a514073864
using Plots

# ╔═╡ 4df26174-9aa3-46d0-879b-aec9a771714b
using LaTeXStrings

# ╔═╡ ea0a7ca2-503f-4d61-a3d4-42503f322782
begin
	using PlutoUI, PlutoTeachingTools
	eval(Meta.parse(code_for_check_type_funcs))
end

# ╔═╡ 4ac5cc73-d8d6-43d5-81b2-944d559fd2ca
md"""
# Astro 528 Lab 2, Exercise 1

## Benchmarking Code


Julia provides several tools for measuring code performance. Perhaps the simplest way is using the [`@time`](https://docs.julialang.org/en/v1.0/base/base/#Base.@time) or [`@elapsed`](https://docs.julialang.org/en/v1.0/base/base/#Base.@elapsed) macros, such as
"""

# ╔═╡ 637f6a84-ad01-43a7-899b-b7867fbe3b3d
@elapsed randn(1000)

# ╔═╡ c23045a0-56b2-4e1e-b5d3-8e248fd1bffd
md"""
The `@time` macro prints the time, but returns the value of the following expression. (Pluto doesn't normally show the output printed to the terminal inside the notebook.  You can either find it in the window where you're running the Pluto server or you can use the `with_terminal()` function provided by PlutoUI.jl to view the output.)  The `@elapsed` macro discards the following expressions return value and returns the elapsed time evaluating the expression.
"""

# ╔═╡ 6dcedd62-c606-43ba-b2f6-e018aefcb035
with_terminal() do 
	@time rand(1000)
end

# ╔═╡ e3bfd6bc-261d-4e69-9ce6-e78d959c13be
md"""There are even more sophisticated macros in the [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) package which provides `@btime` and `@belapsed` that provide outputs similar to `@time` and `@elapsed`.  However, these take longer than @time and `@elapsed`, since they run the code multiple times in an attempt to give more accurate results.  It also provides a `@benchmkark` macro that is quite flexible and provides even more detailed information.  
"""

# ╔═╡ 2a5eb6c7-9b8c-4923-8fe4-e7211c6c820f
md"Let's define a function, `my_function_0_args` that takes a single arguement, the number of samples, and calls a mathematical function with zero arguments (e.g., `rand`) to be benchmarked for a given problem size.  "

# ╔═╡ b3e64508-319f-4506-8512-211e30be4bee
my_function_0_args(N::Integer) = rand(N)

# ╔═╡ a0a24490-3136-45e4-8f55-44448d8366d1
md"Next, we'll specificy what problem sizes you'd like to benchmark as a vector of integers named `num_list`.  (At some point you may want to add larger problem sizes, but beware that that will result in a delay while the rest of the notebook updates.)"

# ╔═╡ 69c39140-ba66-4345-869c-a5499d5d4376
num_list = [1,2,4,8,16,32,64,128,256,512]

# ╔═╡ 2e0b53c8-4107-485f-9f33-d921b6fc0c05
md"I've provided a function `benchmark_my_funciton` at the bottom of the notebook that will help us compactly compute benchmarks for `my_function_0_args`."

# ╔═╡ 928fe18c-2b34-427f-afdb-6273a0ce135e
md"Now, we'll generate several datasets (containing randomly generated values) to use for testing function with different size arrays here, so that we don't have to keep regenerating datasets over and over."

# ╔═╡ fd7c88ef-02fb-408f-a551-45a93d873ded
begin
	x_list = rand.(num_list)
	y_list = rand.(num_list)
end;

# ╔═╡ ba4b35c8-0fe8-4a25-9817-d13c0cd98c6f
md"We'll start by benchmarking the square root function when applied to each element of an array."

# ╔═╡ bb4e3e7e-d8da-4c53-b861-0e66237aae3c
sqrt_broadcasted(x) = sqrt.(x);

# ╔═╡ 6e1e699f-4f4a-4a21-946f-e763eb106f37
md"Now try benchmarking one or two univariate functions of your own and comparing them to `sqrt`.  Write a function `my_function_1_arg` that takes an array and applies a function of your choice to the input array."

# ╔═╡ 39ed7918-8926-4866-8b25-c61dbbd35991
my_function_1_arg(x::Array) = missing

# ╔═╡ a403c0f3-fc4a-4bc1-87c4-8a2d5d15e1a0
begin
	my_function_1_arg_is_good_to_go = false
	if !@isdefined(my_function_1_arg)
		func_not_defined(:my_function_1_arg)
	elseif length(methods(my_function_1_arg,[Array,])) <1
		PlutoTeachingTools.warning_box(md"`my_function_1_arg` should take an  `Array` as its arguement")
	elseif ismissing(my_function_1_arg([1,2,3]))
		still_missing()
	elseif size(my_function_1_arg([1,2,3]))!=(3,)
		almost(md"The size of the `my_function_1_arg`'s output doesn't match the size of the input.")
	else
		my_function_1_arg_is_good_to_go = true
		correct()
	end
end

# ╔═╡ 5d234d6c-be3d-4d0f-bd58-774b6786db54
md"Now, let's try benchmarking some functions that take two variables."

# ╔═╡ aa8367f9-33f4-490e-851b-5f02f15db48d
aside(tip(md"This is a short-hand way to write a small function.  It's often used for small internal functions that aren't intended to be reused."))

# ╔═╡ 11df2b04-2bef-497e-a064-cbcd159aecc7
add_broadcasted(x, y) = x.+y;

# ╔═╡ 8320739f-ec14-4a49-b374-a0baa198f646
function mul_broadcasted(x::Array, y::Array) 
	x.*y 
end

# ╔═╡ e352d85a-b8ce-4355-8b0b-9c28465dd006
div_broadcasted(x,y) = x./y;

# ╔═╡ 2741fd1e-e650-4411-ac4f-9ccb855608c4
protip(md"There is a more verbose way of writing `x.*y`.  
```julia
function mul_loop(x::Array, y::Array)
	@assert size(x) == size(y)  
	@assert eltype(x) == eltype(y)
	z = Array{eltype(x)}(undef,size(x))
	for i in eachindex(x,y) 
		z[i] = x[i] * y[i]
	end
	z
end
```
This allows us to be a little more careful.  We enforce that the arguements must be arrays of the same size and that the type of the data contained in the two input arrays matches.  We also write out a loop over all elements of the arrays explicitly.  In some languages, this can result in very poor performance.  In Julia, it's still very fast, allowing you to write functions however is easiest for you.  For a 1-d array, we might have written `for i in 1:length(x)`.  Instead, we've used `eachindex` to make the function *generic* in the sense that it can work with arrays of arbitrary dimensions, not just 1-d arrays (i.e., vectors).  If you benchmark it, you'll find it appears to be slower, but this is due to the fact that it's counting the time required to allocate memory for the output, which is not included when benchmarking the `mul_broadcasted` version.")

# ╔═╡ 0ce6409c-3aa4-4446-ae13-81c4e743d322
md"Create a function `my_function_2_args` that takes two arrays and applies computes a function of your choice to them."

# ╔═╡ f13619d1-6ece-42be-965d-ab6bb9e9b8cd
my_function_2_args(x::Array, y::Array) = missing

# ╔═╡ 340808ea-e99b-4de7-ad55-b2d812ff0f4d
begin
	my_function_2_args_is_good_to_go = false
	if !@isdefined(my_function_2_args)
		func_not_defined(:my_function_2_args)
	elseif length(methods(my_function_2_args,[Array,Array])) <1
		PlutoTeachingTools.warning_box(md"`my_function_2_args` should take two `Array`'s as arguemetns")
	elseif ismissing(my_function_2_args([1,2,3],[4,5,6]))
		still_missing()
	elseif size(my_function_2_args([1,2,3],[4,5,6]))!=(3,)
		almost(md"The size of the `my_function_2_args`'s output doesn't match the size of the input.")
	else
		my_function_2_args_is_good_to_go = true
		correct()
	end
end

# ╔═╡ 3621793a-427b-40d2-b28d-7bb9c6f3a28c
md"""
Now, it's your turn.  Try updating `my_function_1_arg` and `my_function_2_args` to compute a few different mathematical functions.  For example, try a couple of trig functions, and a logarithm. 
"""

# ╔═╡ 10499798-1ba6-4a2f-827b-aecc4a1f8346
md"""
a.  How much longer did it take to compute a trig function than simple arithmetic?
How much longer did it take to compute a logarithm than simple arithmetic?
"""

# ╔═╡ ffde1960-8792-4092-9a0b-42b2726bb2da
response_1a = missing

# ╔═╡ 10f54651-4b05-4806-9a0c-cb0b6afa245b
display_msg_if_fail(check_type_isa(:response_1a,response_1a,Markdown.MD)) 

# ╔═╡ 2291567f-71a4-4a53-a80c-aab58f29ddf8
md"""
b.  Did the number of evaluations per second vary significantly depending on the number of elements in the array?  
How large of an array was necessary before the performance reached its asymptote?
"""

# ╔═╡ 05e772d4-a2ad-4f16-866c-b8aa3ab7a550
response_1b = missing

# ╔═╡ eb1ff48b-7dbc-4b37-a18d-77eadc568f5a
display_msg_if_fail(check_type_isa(:response_1b,response_1b,Markdown.MD)) 

# ╔═╡ c888afb4-59da-4d7b-a050-df84f3735202
md"""
## Memory Requirements for Linear Algebra Problems[^acklmemreq] 

Consider a modern laptop with 4 GB ($=4*2^{30}$) of usable memory. Assume it uses 8 bytes of memory to store each floating point number (i.e., Float64, double precision, real\*8).   Feel free to add some cells with code to compute the answers to the equestions below.
"""

# ╔═╡ b9157cf9-99da-46ee-8ba0-ed6a95153f74
md"""
### Theory
c. What is the number of rows in the largest square matrix that the above computer could fit into its available memory at one time? 

"""

# ╔═╡ b0873452-b9b5-4bc5-bb76-5f299a6d366e
response_1c = missing

# ╔═╡ cc584d2a-2a3b-4898-b753-1a7275712ad2
display_msg_if_fail(check_type_isa(:response_1c,response_1c,Integer)) 

# ╔═╡ e69c7809-ec6c-4f3a-b869-100381d40bf9
if !@isdefined(response_1c)  || ismissing(response_1c)
	nothing
elseif response_1c == floor(Int,sqrt(4*2^30/8))
	correct()
else
	almost(md"Try again")
end

# ╔═╡ ea68d6eb-a542-44bf-b0e7-815e2372bc33
md"""
d. Estimate how long (in seconds) would it take to solve the maximum size linear system that would fit into memory at once, if we use LU factorization to solve a linear system.  You may assume the computation is maximally efficient, the computer reaches peak performance and the LU decomposition requires $(2/3)*N^3$ floating point operations, where $N$ refers to the number of rows in the square array being factorized.
Use an approximation for the number of floating point operations per second based on your results above."""

# ╔═╡ 484b47d6-65de-497a-b78f-6996c8787de8
response_1d = missing

# ╔═╡ 8e2045c2-c5de-4895-9719-efb9de113dec
display_msg_if_fail(check_type_isa(:response_1d,response_1d,Real)) 

# ╔═╡ 2da17c61-a8d7-4dc2-8209-69fe809e9d4f
begin
	local N = floor(Int,sqrt(4*2^30/8))
	local num_ops = (2//3)*N^3
	local my_flops = 1.5e9
	local my_est = num_ops/my_flops
	if !@isdefined(response_1d)  || ismissing(response_1d)
		nothing
	elseif response_1d < my_est/10
		almost(md"Are you sure?  That seems low to me.")
	elseif response_1d > my_est*10
		almost(md"Are you sure?  That seems high to me.")
	else
		correct(md"That seems like a plaussible runtime to me.")	
	end
end

# ╔═╡ 4e8e86ed-92b0-4aa5-945b-ef6193cb2559
md"""
e. Does memory or compute time limit the size of system that can be practically solved with LU decomposition for this modern laptop?"""

# ╔═╡ 1d4275fd-3208-477d-b26e-be23940035ba
response_1e = missing

# ╔═╡ c64bd8d8-6801-46a7-876b-c75b83300416
display_msg_if_fail(check_type_isa(:response_1e,response_1e,Markdown.MD)) 

# ╔═╡ 5cc54a66-461c-4bb3-8e29-2079adeff04f
md"""f. Now consider a high-end server with 1TB of RAM (such as Roar Collabs's high-memory nodes).  
How many rows are in the largest square matrix that would fit into its memory at once?"""

# ╔═╡ 30efc3ea-a2a2-48f8-833f-6b51845e47dc
response_1f = missing

# ╔═╡ 33bc47b6-f48b-4e24-bb54-fa794f04e166
display_msg_if_fail(check_type_isa(:response_1f,response_1f,Integer)) 

# ╔═╡ 3fab2e27-766c-4464-9b6c-e5235a80183a
if !@isdefined(response_1f)  || ismissing(response_1f)
	nothing
elseif response_1f == floor(Int,sqrt(1024*2^30/8))
	correct()
else
	almost(md"Try again")
end

# ╔═╡ 9af89fd2-a5f6-4807-beb6-d3fa9fa89b69
md"""1g. How long do you estimate it would take (assuming performance similar to the system you're using)?"""

# ╔═╡ 7e42beb2-f525-40c4-9332-5c0b4bd27e9c
response_1g = missing

# ╔═╡ 4d3b7121-8409-492f-8de5-7cc7859f193f
display_msg_if_fail(check_type_isa(:response_1g,response_1g,Real)) 

# ╔═╡ a847804b-886e-4046-a7b8-52f3fbfc9376
begin
	local N = floor(Int,sqrt(1024*2^30/8))
	local num_ops = (2//3)*N^3
	local my_flops = 1.5e9
	local my_est = num_ops/my_flops
	if !@isdefined(response_1g)  || ismissing(response_1g)
		nothing
	elseif response_1g < my_est/10
		almost(md"Are you sure?  That seems low to me.")
		correct()
	elseif response_1g > my_est*10
		almost(md"Are you sure?  That seems high to me.")
	else
		correct(md"That seems like a plaussible runtime to me.")	
	end
end

# ╔═╡ 702843dc-83a9-4fde-b7fa-989e1e5e6c88
md"1h. Does memory or run-time limit the largest matrix that can facotrized on a high-end server?  Why?"

# ╔═╡ 59e0467c-a8a8-43fe-a735-146e001a14fb
response_1h = missing

# ╔═╡ 64c04240-24a4-4d1e-b03d-3ca8dd1fdd38
display_msg_if_fail(check_type_isa(:response_1h,response_1h,Markdown.MD)) 

# ╔═╡ 607ebb54-065f-44e9-a66c-686dae2dcd54
md"""
### In practice

i. Following your work above, estimate how long (in seconds) it would take to solve a linear system with $N=100$ via LU factorization.  
"""

# ╔═╡ dc2116e4-5995-4b81-8d19-3656da4c34dc
response_1i = missing

# ╔═╡ 5dc61f62-57f0-4c1e-9373-d6d00931d12d
display_msg_if_fail(check_type_isa(:response_1i,response_1i,Real)) 

# ╔═╡ 62dd7c5b-21a3-4c53-99a7-b6f7e57e39f2
begin
	local N = 100
	local num_ops = (2//3)*N^3
	local my_flops = 1.5e9
	local my_est = num_ops/my_flops
	if !@isdefined(response_1i)  || ismissing(response_1i)
		nothing
	elseif response_1i < my_est/10
		almost(md"Are you sure?  That seems low to me.")
		correct()
	elseif response_1i > my_est*10
		almost(md"Are you sure?  That seems high to me.")
	else
		correct(md"That seems like a plaussible runtime to me.")	
	end
end

# ╔═╡ 261c65e6-c93e-4253-b828-a92ef90ed797
md"""h.  Now, we'll benchmark how long it actually takes to solve a linear system with $N=100$ via [LU factorization](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/index.html#LinearAlgebra.lu) and the ["left division operator" (`\`)](https://docs.julialang.org/en/v1/base/math/#Base.:\\-Tuple{Any,%20Any}) using the following function and `@time` (_not_ `@btime`).  Importantly, we're going to repeat this a few times.  
"""

# ╔═╡ 9a8c7c33-0e71-42fa-b2a3-e6bbd17c2b81
N = 100  # Set problem size

# ╔═╡ ca8ca136-d01a-4909-90df-331b82f1b8f5
begin  # Create problem data
	A = rand(N,N)
	x = rand(N)
	y = A*x
end;

# ╔═╡ 23f7567b-3493-407e-a251-58d5dbecaed1
"""
   `solve_Ax_via_LU_factorization(A, y)`
Solve the equation y = A x for x using LU Factorization.
See the [Julia manual](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/index.html#LinearAlgebra.lu) for implementation details.
"""
function solve_Ax_via_LU_factorization(A::Matrix, y::Vector)
   	local F = lu(A)   
   	local x = F \ y
end

# ╔═╡ 1d3f387e-caed-4b60-a74a-8576875b9270
with_terminal() do 
	@time x1 = solve_Ax_via_LU_factorization(A,x)
	@time x2 = solve_Ax_via_LU_factorization(A,x)
	@time x3 = solve_Ax_via_LU_factorization(A,x)
end

# ╔═╡ afeda1b5-75ae-4c82-a5eb-d6853083ce14
md"""
j.  Is there any noticeable difference in your three results?  If so, what do you think explains the difference?"""

# ╔═╡ 06da82e6-256e-4a46-b8d5-090e6595940c
response_1j = missing

# ╔═╡ 324e7a1d-cb0b-4c01-893f-672ecffcd2fa
display_msg_if_fail(check_type_isa(:response_1j,response_1j,Markdown.MD)) 

# ╔═╡ 5330262e-74a1-4c0e-8ba9-c458deeb8f6a
md"""Now, try try benchmarking the same code using the `@benchmark` macro.  (This will take several seconds.)"""

# ╔═╡ 26921972-788f-412d-856d-3edd6c2c93b1
aside(tip(md"`@benchmark` is a macro.  Macros take code as input and transform it into (usually longer and more complicated) code as output.  In order to make sure that Julia can optimze the code appropriately we *interpolate* the variables `A` and `x` using the `$` symbol."))

# ╔═╡ ef6e093f-613a-47ed-bcb1-f593f41cf73a
@benchmark solve_Ax_via_LU_factorization($A,$x) seconds=5

# ╔═╡ f43b83a3-2560-4036-b6f4-20cc3860efb0
md"""
k.  Is there a significant difference between the minimum and maximum time required?  If so, what do you think is the biggest effect in explaining the difference?  Which output do you think is most relevant for your typical scientific applications?  """

# ╔═╡ d985b122-1ea7-4dc7-b724-45eb77bcf146
response_1k = missing

# ╔═╡ 03a78cda-38ba-4c74-b777-1a51dacc223c
display_msg_if_fail(check_type_isa(:response_1k,response_1k,Markdown.MD)) 

# ╔═╡ e86ed6db-6e4a-4652-9e1b-7a6a5c168927
md"""l.  How does your result compare to what you estimated analytically in part i?"""

# ╔═╡ a8fe454d-34c4-4619-ace4-610975a8df5f
response_1l = missing

# ╔═╡ 50902545-34bb-4e77-88b7-afc4dac439ec
display_msg_if_fail(check_type_isa(:response_1l,response_1l,Markdown.MD)) 

# ╔═╡ 7c98f340-2719-4230-a7ae-e69db51e66cb
md"""
## Scaling with Problem Size
"""

# ╔═╡ 616fabd6-0ea7-4524-a6a1-c4c60d4f87d0
md"""
Next, lets consider several relatively small problem sizes (e.g., no larger than a few hundred) and benchmark `solve_Ax_via_LU_factorization` to see how the performance scales as we increase $N$.  We'll plot the results on a log-log scale and compare to a simplistic analytic model.
"""

# ╔═╡ cdfbad83-736b-44ac-a792-3bbc37fb1076
N_list = 2 .^(1:9)

# ╔═╡ 84539bf8-d5e4-4f75-b5fb-1197ca6221f2
begin
	time_for_one_fma = @belapsed 17.0*π+4.0
	model_time_list = time_for_one_fma * 2//3 .* N_list.^3 
end;

# ╔═╡ fb07fab4-89e4-4e59-bfb5-2e3fd5e26f37
begin
	time_list = zeros(length(N_list))
	for (i,N) in enumerate(N_list)
	  local A = rand(N,N)
	  local x = rand(N)
	  local y = A*x
	  time_list[i] = @belapsed solve_Ax_via_LU_factorization($A,$y)
	end
	time_list
end;

# ╔═╡ 3715f7c6-48c7-4706-a7b7-1757c2891240
begin
	plt = plot()
	plot!(plt,log10.(N_list),log10.(model_time_list), xlabel=L"\log_{10} N", ylabel = L"\log_{10}(\mathrm{Time}/s)", label="Model", legend=:bottomright) 
	scatter!(plt,log10.(N_list),log10.(time_list), label="Actual") 
	plt
end

# ╔═╡ 20cd5f33-d865-470a-9ef4-0cd18a5bba00
md"""
n. How does the actual performance compare the analytic model?  What is your guess for the cause of any deviations?"""

# ╔═╡ ac0374ce-9a02-4fdb-a1e9-5e6fac9192c2
response_1n = missing

# ╔═╡ ba2c71eb-ff66-43a1-8056-982ccfb41510
display_msg_if_fail(check_type_isa(:response_1n,response_1n,Markdown.MD)) 

# ╔═╡ 9ad38265-3d12-4df5-b251-bf7f19fe8947
md"o. For real life problems, what other considerations are likely to limit performance?"

# ╔═╡ c06d4df7-b8ff-493e-b933-eee61baaf651
response_1o = missing

# ╔═╡ 732cf450-0330-43fa-aa0b-6c0fb1b02fd7
display_msg_if_fail(check_type_isa(:response_1o,response_1o,Markdown.MD)) 

# ╔═╡ 19617de2-d198-43d6-a3da-71b7cdfc0be1
md"p. How could one practically solve even larger linear systems?"

# ╔═╡ 7c0a4bda-cd4b-4bef-a2f6-84efe76670aa
response_1p = missing

# ╔═╡ ec7d8268-7f97-4ba3-a0ab-717506002fb6
display_msg_if_fail(check_type_isa(:response_1p,response_1p,Markdown.MD)) 

# ╔═╡ fb3f1372-a7fc-4698-a8ce-d96354520a63
md"""[^acklmemreq]: Acknowledgment:  The questions in this subsection are based on Oliveira & Stewarts Writing Scientific Software, Chapter 5, Problem #6.
"""

# ╔═╡ 07653065-2ef3-4a63-a25b-1b308c22aff5
md"## Helper code"

# ╔═╡ b5103197-8961-4fc0-99c9-50fee4e15a1c
FootnotesNumbered()

# ╔═╡ 5b88a5a8-425b-4ecf-a26a-08722d12ef95


# ╔═╡ 9b2cdb77-9330-4a8b-84b5-deed94c19662
begin
"""
	   `benchmark_my_funciton(f,n_list)`
	   `benchmark_my_funciton(f,x_list)`
	   `benchmark_my_funciton(f,x_list, y_list)`
	
	Benchmarks a user-proved function.  
	User-provided function may take the number of samples, one array or two arrays.
	Returns NamedTuple with two lists (num_list, times_list) containing the number of samples and the runtime.
"""
	function benchmark_my_funciton end
	
	function benchmark_my_funciton(f::Function, num_list::Vector{T} ) where { T<:Integer }
		times_list = zeros(length(num_list))
		for (i,n) in enumerate(num_list)
			times_list[i] = @belapsed $f($n)
		end
		return (;num_list, times_list)
	end
	
	function benchmark_my_funciton(f::Function, x_list::Vector{A} ) where { A<:AbstractArray } 
		times_list = zeros(length(x_list))
		for (i,x) in enumerate(x_list)
			times_list[i] = @belapsed $f($x)
		end
		return (;num_list, times_list)
	end
	
	function benchmark_my_funciton(f::Function, x_list::Vector{A}, y_list::Vector{A} ) where { A<:AbstractArray } 
		@assert length(x_list) == length(y_list)
		times_list = zeros(length(x_list))
		for i in 1:length(x_list)
			x = x_list[i]
			y = y_list[i]
			times_list[i] = @belapsed $f($x,$y)
		end
		return (;num_list, times_list)
	end
end

# ╔═╡ 6b2d4a5c-80bc-4620-9e8a-d8684302a9f2
benchmarks_0 = benchmark_my_funciton(my_function_0_args, num_list)

# ╔═╡ 17c29c66-91f8-45e2-b1f2-337dd51a6e03
begin
		plt0 = scatter(benchmarks_0.num_list, log10.(benchmarks_0.num_list./benchmarks_0.times_list), xscale=:log10, label=:none)
		xlabel!(plt0, "Size of Array")
		ylabel!(plt0, "log_10 (Evals/s)")
		title!(plt0,"Benchmarks for my_function_0_args")
		plt0
end

# ╔═╡ 4e1f8fa4-b846-4cbd-a5de-b9e137ec04f9
benchmarks_sqrt = benchmark_my_funciton(sqrt_broadcasted, x_list)

# ╔═╡ 185fac9d-ea9e-460a-8f90-d5dad528ed4b
if my_function_1_arg_is_good_to_go
	benchmarks_1 = benchmark_my_funciton(my_function_1_arg, x_list)
end

# ╔═╡ 79716270-4570-41cb-9746-394eead121ee
begin
		plt1 = plot()
		scatter!(plt1,benchmarks_sqrt.num_list, log10.(benchmarks_sqrt.num_list./benchmarks_sqrt.times_list), xscale=:log10, label="sqrt", legend=:topleft)
		if my_function_1_arg_is_good_to_go
			scatter!(plt1,benchmarks_1.num_list, log10.(benchmarks_1.num_list./benchmarks_1.times_list), label="my_function_1_args")
	end
		xlabel!(plt1, "Size of Array")
		ylabel!(plt1, "log₁₀(Evals/s)")
		title!(plt1,"Benchmarks for univariate functions")
		plt1
end

# ╔═╡ d5322db3-501f-467f-a3f4-297258bc2570
benchmarks_add = benchmark_my_funciton(add_broadcasted, x_list, y_list)

# ╔═╡ fffd69c6-47d6-411c-ba57-9c52e659f598
benchmarks_mul = benchmark_my_funciton(mul_broadcasted, x_list, y_list)

# ╔═╡ 4a45fa07-f4dd-4a76-8bd1-8627060a6fc5
benchmarks_div = benchmark_my_funciton(div_broadcasted, x_list, y_list)

# ╔═╡ 930a527f-9eef-43bf-970d-3a17285a233c
if my_function_2_args_is_good_to_go
	benchmarks_2 = benchmark_my_funciton(my_function_2_args, x_list, y_list)
end

# ╔═╡ d73bc561-1063-4020-bba8-d89464d31254
begin
		plt2 = plot()
		scatter!(plt2,benchmarks_add.num_list, log10.(benchmarks_add.num_list./benchmarks_add.times_list), xscale=:log10, label="add Float64s", legend=:topleft)
		scatter!(plt2,benchmarks_mul.num_list, log10.(benchmarks_mul.num_list./benchmarks_mul.times_list), label="multiply Float64s")
		scatter!(plt2,benchmarks_div.num_list, log10.(benchmarks_div.num_list./benchmarks_div.times_list), label="divide Float64s")
		if my_function_2_args_is_good_to_go
			scatter!(plt2,benchmarks_2.num_list, log10.(benchmarks_2.num_list./benchmarks_2.times_list), label="my_function_2_args")
		end

		xlabel!(plt2, "Size of Array")
		ylabel!(plt2, "log_10 (Runtime/s)")
		title!(plt2,"Benchmarks for functions of 2 variables")
		plt2
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "747ef1663ae3a6c01057fcd344163e1ee4ccd428"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "e38fbc49a620f5d0b660d7f543db1009fe0f8336"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.6.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fde3bf89aead2e723284a8ff9cdf5b551ed700e8"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.5+0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "a656525c8b46aa6a1c76891552ed5381bb32ae7b"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.30.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

    [deps.ColorVectorSpace.weakdeps]
    SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "0037835448781bb46feb39866934e243886d756a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "d9d26935a0bcffc87d2613ce14c527c99fc543fd"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.0"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7bb1361afdb33c7f2b085aa49ea8fe1b0fb14e58"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.7.1+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "83dc665d0312b41367b7263e8a4d172eac1897f4"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.4"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3a948313e7a41eb1db7a1e733e6335f17b4ab3c4"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "7.1.1+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "fcb0584ff34e25155876418979d4c8971243bb89"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "1828eb7275491981fa5f1752a5e126e8f26f8741"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.17"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "27299071cc29e409488ada41ec7643e0ab19091f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.17+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "35fbd0cefb04a516104b8e183ce0df11b70a3f1a"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.84.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "ed5e9c58612c4e081aecdb6e1a479e18462e041e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e95866623950267c1e4878846f848d94810de475"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.2+0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "52e1296ebbde0db845b356abbbe67fb82a0a116c"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.9"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "706dfd3c0dd56ca090e86884db6eda70fa7dd4af"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.1+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d3c8af829abaeba27181db4acb485b18d15d89c6"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.1+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "f1a7e086c677df53e064e0fdd2c9d0b0833e3f6e"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.5.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "2ae7d4ddec2e13ad3bddf5c0796f7547cf682391"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.2+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c392fc5dd032381919e3b22dd32d6443760ce7ea"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.5.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "275a9a6d85dc86c24d03d1837a0010226a96f540"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.3+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "0c5a5b7e440c008fe31416a3ac9e0d2057c81106"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.19"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "Latexify", "Markdown", "PlutoUI"]
git-tree-sha1 = "85778cdf2bed372008e6646c64340460764a5b85"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.4.5"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "fcfec547342405c7a8529ea896f98c0ffcc4931d"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.70"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "0f27480397253da18fe2c12a4ba4eb9eb208bf3d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Profile]]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "eb38d376097f47316fe089fc62cb7c6d85383a52"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.8.2+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll"]
git-tree-sha1 = "da7adf145cce0d44e892626e647f9dcbe9cb3e10"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.8.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "9eca9fc3fe515d619ce004c83c31ffd3f85c7ccf"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.8.2+1"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "e1d5e16d0f65762396f9ca4644a5f4ddab8d452b"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.8.2+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "95af145932c2ed859b63329952ce8d633719f091"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9d72a13a3f4dd3795a195ac5a44d7d6ff5f552ff"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.1"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2c962245732371acd51700dbb268af311bddd719"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.6"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "372b90fe551c019541fafc6ff034199dc19c8436"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.12"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "6258d453843c466d84c17a58732dda5deeb8d3af"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.24.0"

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    ForwardDiffExt = "ForwardDiff"
    InverseFunctionsUnitfulExt = "InverseFunctions"
    PrintfExt = "Printf"

    [deps.Unitful.weakdeps]
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"
    Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "af305cc62419f9bd61b6644d19170a4d258c7967"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.7.0"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fee71455b0aaa3440dfdd54a9a36ccef829be7d4"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.1+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "b5899b25d17bf1889d25906fb9deed5da0c15b3b"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.12+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a4c0ee07ad36bf8bbce1c3bb52d21fb1e0b987fb"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.7+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "9caba99d38404b285db8801d5c45ef4f4f425a6d"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.1+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "a5bc75478d323358a90dc36766f3c99ba7feb024"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.6+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "aff463c82a773cb86061bce8d53a0d976854923e"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.5+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "e3150c7400c41e207012b41659591f083f3ef795"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.3+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "c5bf2dad6a03dfef57ea0a170a1fe493601603f2"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.5+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4bba74fa59ab0755167ad24f98800fe5d727175b"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.12.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "125eedcb0a4a0bba65b657251ce1d27c8714e9d6"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.4+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "07b6a107d926093898e82b3b1db657ebe33134ec"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.50+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "fbf139bce07a534df0e699dbb5f5cc9346f95cc1"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.9.2+0"
"""

# ╔═╡ Cell order:
# ╟─4ac5cc73-d8d6-43d5-81b2-944d559fd2ca
# ╠═637f6a84-ad01-43a7-899b-b7867fbe3b3d
# ╟─c23045a0-56b2-4e1e-b5d3-8e248fd1bffd
# ╠═6dcedd62-c606-43ba-b2f6-e018aefcb035
# ╟─e3bfd6bc-261d-4e69-9ce6-e78d959c13be
# ╠═0854551f-fc6d-4c51-bf85-a9c7030e588b
# ╟─2a5eb6c7-9b8c-4923-8fe4-e7211c6c820f
# ╠═b3e64508-319f-4506-8512-211e30be4bee
# ╟─a0a24490-3136-45e4-8f55-44448d8366d1
# ╠═69c39140-ba66-4345-869c-a5499d5d4376
# ╟─2e0b53c8-4107-485f-9f33-d921b6fc0c05
# ╠═6b2d4a5c-80bc-4620-9e8a-d8684302a9f2
# ╟─17c29c66-91f8-45e2-b1f2-337dd51a6e03
# ╟─928fe18c-2b34-427f-afdb-6273a0ce135e
# ╠═fd7c88ef-02fb-408f-a551-45a93d873ded
# ╟─ba4b35c8-0fe8-4a25-9817-d13c0cd98c6f
# ╠═bb4e3e7e-d8da-4c53-b861-0e66237aae3c
# ╠═4e1f8fa4-b846-4cbd-a5de-b9e137ec04f9
# ╟─6e1e699f-4f4a-4a21-946f-e763eb106f37
# ╠═39ed7918-8926-4866-8b25-c61dbbd35991
# ╟─a403c0f3-fc4a-4bc1-87c4-8a2d5d15e1a0
# ╟─185fac9d-ea9e-460a-8f90-d5dad528ed4b
# ╟─79716270-4570-41cb-9746-394eead121ee
# ╟─5d234d6c-be3d-4d0f-bd58-774b6786db54
# ╟─aa8367f9-33f4-490e-851b-5f02f15db48d
# ╠═11df2b04-2bef-497e-a064-cbcd159aecc7
# ╠═d5322db3-501f-467f-a3f4-297258bc2570
# ╠═8320739f-ec14-4a49-b374-a0baa198f646
# ╠═fffd69c6-47d6-411c-ba57-9c52e659f598
# ╠═e352d85a-b8ce-4355-8b0b-9c28465dd006
# ╠═4a45fa07-f4dd-4a76-8bd1-8627060a6fc5
# ╟─2741fd1e-e650-4411-ac4f-9ccb855608c4
# ╟─0ce6409c-3aa4-4446-ae13-81c4e743d322
# ╠═f13619d1-6ece-42be-965d-ab6bb9e9b8cd
# ╟─340808ea-e99b-4de7-ad55-b2d812ff0f4d
# ╠═930a527f-9eef-43bf-970d-3a17285a233c
# ╟─d73bc561-1063-4020-bba8-d89464d31254
# ╟─3621793a-427b-40d2-b28d-7bb9c6f3a28c
# ╟─10499798-1ba6-4a2f-827b-aecc4a1f8346
# ╠═ffde1960-8792-4092-9a0b-42b2726bb2da
# ╟─10f54651-4b05-4806-9a0c-cb0b6afa245b
# ╟─2291567f-71a4-4a53-a80c-aab58f29ddf8
# ╠═05e772d4-a2ad-4f16-866c-b8aa3ab7a550
# ╟─eb1ff48b-7dbc-4b37-a18d-77eadc568f5a
# ╟─c888afb4-59da-4d7b-a050-df84f3735202
# ╟─b9157cf9-99da-46ee-8ba0-ed6a95153f74
# ╠═b0873452-b9b5-4bc5-bb76-5f299a6d366e
# ╟─cc584d2a-2a3b-4898-b753-1a7275712ad2
# ╟─e69c7809-ec6c-4f3a-b869-100381d40bf9
# ╟─ea68d6eb-a542-44bf-b0e7-815e2372bc33
# ╠═484b47d6-65de-497a-b78f-6996c8787de8
# ╟─8e2045c2-c5de-4895-9719-efb9de113dec
# ╟─2da17c61-a8d7-4dc2-8209-69fe809e9d4f
# ╟─4e8e86ed-92b0-4aa5-945b-ef6193cb2559
# ╠═1d4275fd-3208-477d-b26e-be23940035ba
# ╟─c64bd8d8-6801-46a7-876b-c75b83300416
# ╟─5cc54a66-461c-4bb3-8e29-2079adeff04f
# ╠═30efc3ea-a2a2-48f8-833f-6b51845e47dc
# ╟─33bc47b6-f48b-4e24-bb54-fa794f04e166
# ╟─3fab2e27-766c-4464-9b6c-e5235a80183a
# ╟─9af89fd2-a5f6-4807-beb6-d3fa9fa89b69
# ╠═7e42beb2-f525-40c4-9332-5c0b4bd27e9c
# ╟─4d3b7121-8409-492f-8de5-7cc7859f193f
# ╟─a847804b-886e-4046-a7b8-52f3fbfc9376
# ╟─702843dc-83a9-4fde-b7fa-989e1e5e6c88
# ╠═59e0467c-a8a8-43fe-a735-146e001a14fb
# ╟─64c04240-24a4-4d1e-b03d-3ca8dd1fdd38
# ╟─607ebb54-065f-44e9-a66c-686dae2dcd54
# ╠═dc2116e4-5995-4b81-8d19-3656da4c34dc
# ╟─5dc61f62-57f0-4c1e-9373-d6d00931d12d
# ╟─62dd7c5b-21a3-4c53-99a7-b6f7e57e39f2
# ╟─261c65e6-c93e-4253-b828-a92ef90ed797
# ╟─9a8c7c33-0e71-42fa-b2a3-e6bbd17c2b81
# ╠═ca8ca136-d01a-4909-90df-331b82f1b8f5
# ╠═cb099d3d-5c09-4c56-9c59-83adab60f651
# ╠═23f7567b-3493-407e-a251-58d5dbecaed1
# ╠═1d3f387e-caed-4b60-a74a-8576875b9270
# ╟─afeda1b5-75ae-4c82-a5eb-d6853083ce14
# ╠═06da82e6-256e-4a46-b8d5-090e6595940c
# ╟─324e7a1d-cb0b-4c01-893f-672ecffcd2fa
# ╟─5330262e-74a1-4c0e-8ba9-c458deeb8f6a
# ╟─26921972-788f-412d-856d-3edd6c2c93b1
# ╠═ef6e093f-613a-47ed-bcb1-f593f41cf73a
# ╟─f43b83a3-2560-4036-b6f4-20cc3860efb0
# ╟─d985b122-1ea7-4dc7-b724-45eb77bcf146
# ╟─03a78cda-38ba-4c74-b777-1a51dacc223c
# ╟─e86ed6db-6e4a-4652-9e1b-7a6a5c168927
# ╟─a8fe454d-34c4-4619-ace4-610975a8df5f
# ╟─50902545-34bb-4e77-88b7-afc4dac439ec
# ╟─7c98f340-2719-4230-a7ae-e69db51e66cb
# ╟─616fabd6-0ea7-4524-a6a1-c4c60d4f87d0
# ╠═cdfbad83-736b-44ac-a792-3bbc37fb1076
# ╟─84539bf8-d5e4-4f75-b5fb-1197ca6221f2
# ╟─fb07fab4-89e4-4e59-bfb5-2e3fd5e26f37
# ╟─3715f7c6-48c7-4706-a7b7-1757c2891240
# ╟─20cd5f33-d865-470a-9ef4-0cd18a5bba00
# ╠═ac0374ce-9a02-4fdb-a1e9-5e6fac9192c2
# ╟─ba2c71eb-ff66-43a1-8056-982ccfb41510
# ╟─9ad38265-3d12-4df5-b251-bf7f19fe8947
# ╠═c06d4df7-b8ff-493e-b933-eee61baaf651
# ╟─732cf450-0330-43fa-aa0b-6c0fb1b02fd7
# ╟─19617de2-d198-43d6-a3da-71b7cdfc0be1
# ╟─7c0a4bda-cd4b-4bef-a2f6-84efe76670aa
# ╟─ec7d8268-7f97-4ba3-a0ab-717506002fb6
# ╟─fb3f1372-a7fc-4698-a8ce-d96354520a63
# ╟─07653065-2ef3-4a63-a25b-1b308c22aff5
# ╠═a1122848-347f-408b-99c2-a7a514073864
# ╠═4df26174-9aa3-46d0-879b-aec9a771714b
# ╠═ea0a7ca2-503f-4d61-a3d4-42503f322782
# ╠═b5103197-8961-4fc0-99c9-50fee4e15a1c
# ╠═5b88a5a8-425b-4ecf-a26a-08722d12ef95
# ╠═9b2cdb77-9330-4a8b-84b5-deed94c19662
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
