module Checkpointer
    export save_checkpoint, read_checkpoint, ReCreateSelfCons

    using ..FixedPointToolkit.SelfConsistency:SelfCons
    using JLD2


@doc """
```julia
save_checkpoint(fileName::String, sc::SelfCons, SelfConsParams::Dict{Symbol, Real})
```

Save the relevant attributed of a `SelfCons` data structure in a JLD2 file `fileName` (`fileName` must end with .jld2). 
Also saves some self-consistency parameters like maximum iteration, tolerance etc.

"""
    function save_checkpoint(fileName::String, sc::SelfCons, SelfConsParams::Dict{Symbol, Real})

        jldopen( fileName , "w" ) do f 
            f["function args"]              =   sc.F_args
            f["function kwargs"]            =   sc.F_kwargs 
            f["inputs"]                     =   sc.VIns
            f["outputs"]                    =   sc.VOuts
            f["Update kwargs"]              =   sc.Update_kwargs
            f["Self-consistency params"]    =   SelfConsParams
        end 
    end


@doc """
```julia
read_checkpoint(fileName::String )
```

Read a JLD2 file `fileName` (`fileName` must end with .jld2) and return the checkpoint in the form of a dictionary. 

"""
    function read_checkpoint(fileName::String )

        local F_args, F_kwargs, VIns, VOuts, Update_kwargs, SelfConsParams

        jldopen( fileName , "r" ) do f 
            F_args          = f["function args"]         
            F_kwargs        = f["function kwargs"]       
            VIns            = f["inputs"]                
            VOuts           = f["outputs"]               
            Update_kwargs   = f["Update kwargs"]         
            SelfConsParams  = f["Self-consistency params"]    
        end 

        return Dict("function args"              => F_args          ,
                    "function kwargs"            => F_kwargs        ,
                    "inputs"                     => VIns            ,
                    "outputs"                    => VOuts           ,
                    "Update kwargs"              => Update_kwargs   ,
                    "Self-consistency params"    => SelfConsParams  )

    end


@doc """
```julia
ReCreateSelfCons(checkpoint::Dict, F::T, Update::R) :: SelfCons where {T<:Function, R<:Function}
```

Return a `SelfCons` structure from a checkpoint dictionary and the function `F` and `Update` (which are not saved during checkpointing).

"""
    function ReCreateSelfCons(checkpoint::Dict, F::T, Update::R) :: SelfCons where {T<:Function, R<:Function}

        initial     =   checkpoint["inputs"][end]
        sc          =   SelfCons(F, checkpoint["function args"], checkpoint["function kwargs"], initial, checkpoint["inputs"], checkpoint["outputs"], Update, checkpoint["Update kwargs"])   

        return sc
    end


end