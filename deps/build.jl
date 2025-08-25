#println("Making sure Pluto is installed")
import Pkg; 
#Pkg.add(name="Pluto", version="0.20.4");
import Pluto; 

println("Installing packages for ex1.jl")
Pluto.activate_notebook_environment("../ex1.jl"); 
Pkg.instantiate(); 

println("Installing packages for ex2.jl")
Pluto.activate_notebook_environment("../ex2.jl"); 
Pkg.instantiate(); 

println("Installing packages for ex4.jl")
Pluto.activate_notebook_environment("../ex4.jl"); 
Pkg.instantiate(); 

println("Installing packages for ex3.jl")
Pluto.activate_notebook_environment("../ex3.jl"); 
Pkg.instantiate(); 

println("Preventing generating html for ex3 everytime.")
println(basename(pwd()))
if !occursin(r"lab2$",pwd())
   println("# Writing PlutoDeployment to avoid exporting ex3.jl everytime.")
   settings = 
   """
   [Export]
   exclude = ["ex3.jl","ex*backup*.jl"] 

   [SliderServer]
   exclude = ["ex3.jl","ex*backup*.jl"]
   """
   write("../PlutoDeployment.toml",settings)   
end

