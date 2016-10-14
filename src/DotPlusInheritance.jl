(.+)(var::Symbol,ex::Union{Expr,Symbol})=eval(DotPlusInheritance.redot(var,dotplus(typeof(eval(var)),ex)))
dotplus(var::Symbol,ex::Union{Expr,Symbol})=DotPlusInheritance.redot(var,dotplus(typeof(eval(var)),ex))
dotplus(var::DataType,ex::Union{Expr,Symbol})=DotPlusInheritance.dotplus(var,ex)

module DotPlusInheritance

  inventory=Dict{DataType,Dict{Symbol,Union{Expr,Symbol}}}()
  inventorytyp=Dict{DataType,Dict{Symbol,DataType}}()

  function redot(from::Symbol,what::Union{Expr,Symbol})
    if isa(what,Symbol)
      return Expr(:.,from,QuoteNode(what))
    else
      return Expr(:.,redot(from,what.args[1]),what.args[2])
    end
  end

  #return dot expression to address a variable of type with parent
  function dotplus(t::DataType,ex::Union{Expr,Symbol})
    symbs=splitdotexpr(ex)
    ex=nothing
    while length(symbs)>0
      exnew,t=getfieldplus(t,pop!(symbs))
      if ex==nothing
        ex=exnew
      else
        symbsnew=splitdotexpr(exnew)
        while length(symbsnew)>0
          ex=Expr(:.,ex,QuoteNode(pop!(symbsnew)))
        end
      end
    end
    return ex
  end

  splitdotexpr(ex::Symbol)=[ex]

  function splitdotexpr(ex::Expr,symbs=nothing)
    if symbs==nothing
      symbs=Array(Symbol,0)
    end
    if !isa(ex.args[1],Symbol)
      push!(symbs,ex.args[2].value)
      splitdotexpr(ex.args[1],symbs)
    else
      push!(symbs,ex.args[2].value)
      push!(symbs,ex.args[1])
      return symbs
    end
  end

  function getfieldplus(t::DataType,sy::Symbol)
    if !haskey(inventory,t)
      # adds type to inventory on first call
      addnamestoinventory(t)
    end
    return inventory[t][sy],inventorytyp[t][sy]
  end

  function addnamestoinventory(t::DataType)
    item::Dict{Symbol,Union{Expr,Symbol}}=Dict{Symbol,Union{Expr,Symbol}}()
    itemtyp::Dict{Symbol,DataType}=Dict{Symbol,DataType}()
    sym,exp,typ=allnames_recurcive(t)
    for i in 1:length(sym)
      item[sym[i]]=exp[i]
      itemtyp[sym[i]]=typ[i]
    end
    inventory[t]=item
    inventorytyp[t]=itemtyp
    return
  end

  function allnames_recurcive(t::DataType)
    parentNames::Array{Symbol,1}=Array(Symbol,0)
    parentTyp::Array{DataType,1}=Array(DataType,0)
    parentExprs::Array{Union{Expr,Symbol},1}=Array(Union{Expr,Symbol},0)

    ret::Array{Symbol,1}=Array(Symbol,0)
    retExpr::Array{Union{Expr,Symbol},1}=Array(Union{Expr,Symbol},0)
    rettyp::Array{DataType,1}=Array(DataType,0)

    na=fieldnames(t)
    j=1
    for i in 1:length(na)
      ty=fieldtype(t,na[i])
      if startswith(string(na[i]),"_base_")
        ap,axp,typ=allnames_recurcive(ty)
        parentNames=vcat(parentNames,ap)
        parentTyp=vcat(parentTyp,typ)
        for j in 1:length(axp)
          axp[j]=redot(na[i],axp[j])
        end
        parentExprs=vcat(parentExprs,axp)
      else
        push!(ret,na[i])
        push!(retExpr,na[i])
        push!(rettyp,ty)
      end
    end
    #over write parent variables
    return vcat(parentNames,ret),vcat(parentExprs,retExpr),vcat(parentTyp,rettyp)
  end
end
