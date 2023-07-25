# FixedPointToolkit.Updates

```@autodocs
Modules = [FixedPointToolkit, FixedPointToolkit.Updates]
Private = false
Pages = ["Updates.jl"]
```

# Hot to write your own Update
If you want to design your own update function, you need to follow certain guidelines
* Define your function as follows (`F` is the function whose fixed point is being calculated)
```julia
function CustomUpdate(VIn::N, VOut::N, F::T ; F_args::Tuple = (), F_kwargs::Dict = Dict(), kwargs..., _extra...) :: Dict where {T<:Function, N<:Union{Number, Vector{<:Number}}}
    ##### Get VInNext by doing something on VIn, VOut, and stuff in kwargs.
    VOutNext    =   F(VInNext, F_args... ; F_kwargs...)

    ##### If you want to include scheduling, you can now include a function which updates the kwargs themselves --> call then new_kwargs (MUST contain all the keys of kwargs, even if they are unchanged)

    return Dict("VInNext"   => VInNext, 
                "VOutNext"  => VOutNext,
                "Delta"     => norm(VOutNext - VInNext) / sqrt(length(VInNext)), 
                "kwargs"    => new_kwargs)
end
```
* Every other argument you pass to your `CustomUpdate` must be a keyword argument. 
* Unlike `CustomScheduler`, you will be able to pass whatever `kwargs` you want to `CustomUpdate` when you begin the Fixed Point iterations.. 

