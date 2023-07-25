# FixedPointToolkit.Scheduler

```@autodocs
Modules = [FixedPointToolkit, FixedPointToolkit.Scheduler]
Private = false
Pages   = ["Scheduler.jl"]
```

# Hot to write your own Scheduler
If you want to design your own scheduler, you need to follow certain guidelines
* Define your function as follows
```julia
    function CustomScheduler(x::Float64 ; iter::Int64, max_iter::Int64, kwargs...)
        ##### Do something with x, iter, max_iter, and any other keyword argument in kwargs
        return x_new
    end
```
* Every other argument you pass to your `CustomScheduler` must be a keyword argument whose default values are set to whatever you want to use during the iterations. 
* You cannot pass these extra `kwargs` during the Fixed point iteration. That is why it is crucial to set their default values to what you need.
* Suppose you want the mixing, $\alpha$ to follow some relation w.r.t iteration $i$, $\alpha = \alpha(i)$. What you want your `CustomScheduler` to return is the next iteration of the mixing, $\alpha(i+1)$, given that $\alpha(i)$, $i$, and other relevant parameters are passed to it. 
* Eg. for an exponential scheduling, 
```julia
    CustomScheduler(x ; iter = i, max_iter = N, rate = r) = x * exp(-r/N)
```
