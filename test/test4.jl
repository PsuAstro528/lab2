using Test

@testset "Testing solution to Exercise 4" begin

@testset "Running ex4.jl" begin
   include("../ex4.jl")
end;

@testset "Testing that variables exist" begin
   @test @isdefined(response_4a)
   @test @isdefined(response_4b)
   @test @isdefined(response_4c)
   @test @isdefined(response_4d)
end;

@testset "Testing that variables are not missing" begin
   @test !ismissing(response_4a)
   @test !ismissing(response_4b)
   @test !ismissing(response_4c)
   @test !ismissing(response_4d)
end;

@testset "Testing that functions' structure" begin
   @test my_function_1_arg_is_good_to_go
   @test my_function_2_args_is_good_to_go
   @test my_function_1_arg_inplace_is_good_to_go
   @test my_function_2_arg_inplace_is_good_to_go
end

end; # Exercise 4
