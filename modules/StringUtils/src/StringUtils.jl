# *****************************************************************************
# Written by Ritchie Lee, ritchie.lee@sv.cmu.edu
# *****************************************************************************
# Copyright ã 2015, United States Government, as represented by the
# Administrator of the National Aeronautics and Space Administration. All
# rights reserved.  The Reinforcement Learning Encounter Simulator (RLES)
# platform is licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You
# may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0. Unless required by applicable
# law or agreed to in writing, software distributed under the License is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language
# governing permissions and limitations under the License.
# _____________________________________________________________________________
# Reinforcement Learning Encounter Simulator (RLES) includes the following
# third party software. The SISLES.jl package is licensed under the MIT Expat
# License: Copyright (c) 2014: Youngjun Kim.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED
# "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# *****************************************************************************

module StringUtils

export hamming, balanced_paren, capitalize_first, dump2string, @printeval
import Base: convert, parse

const TRUES = String["TRUE", "T", "+", "1", "1.0", "POS", "POSITIVE"]
const FALSES = String["FALSE", "F", "-1", "0", "0.0", "NEG", "NEGATIVE"]


function hamming(s1::AbstractString, s2::AbstractString)
    x = collect(s1)
    y = collect(s2)
    minlen = min(length(x), length(y))
    len_diff = abs(length(x) - length(y))
    return sum(x[1:minlen] .!= y[1:minlen]) + len_diff
end

convert{S<:AbstractString,N<:Number}(::Type{S}, x::N) = string(x)
convert{T<:Number}(::Type{T}, s::AbstractString) = parse(T, s)
function convert(::Type{Bool}, s::AbstractString)
    s = uppercase(s)
    if in(s, TRUES)
        return true
    elseif in(s, FALSES)
        return false
    else
        throw(InexactError())
    end
end

#returns the index of the corresponding closing parenthesis
#start_index = index of open parenthesis
function balanced_paren(s::AbstractString, start_index::Int64,
                        open_char::Char='(', close_char::Char=')')
    if s[start_index] != open_char
        warn("balanced_paren: start_index not pointing to open_char")
        return 0
    end
    num_open = 0
    for i = start_index:length(s)
        if s[i] == open_char
            num_open += 1
        elseif s[i] == close_char
            num_open -= 1
        end
        if num_open <= 0
            return i
        end
    end
    return 0
end

capitalize_first(s::AbstractString) = string(uppercase(s[1]), s[2:end])

function dump2string(x)
    io = IOBuffer()
    dump(io, x)
    return takebuf_string(io)
end

macro printeval(line)
    p = :(println($(sprint(Base.show_unquoted, line))))
    ex = quote
        $p
        $(esc(line))
    end
    return ex
end

"""
Convert a string to a Vector of numbers
"""
function parse{T<:Number}(::Type{Vector{T}}, s::String)
    rex = r"^[^\[]*\[([^\]]+)]$"
    m = match(rex, s)
    v = map(x->parse(T,x), split(m.captures[1], ','))
    v
end

function convert(::Type{Vector{String}}, s::String)
    rex = r"^[^\[]*\[([^\]]+)]$"
    m = match(rex, s)
    toks = split(replace(m.captures[1], "\"", ""), ',') #remove quotes and split
    map!(x->replace(x, "\\\\", "\\"), toks) #extra slashes are introduced when calling string, remove them
    out = convert(Vector{String}, toks)
    out
end

function convert(::Type{Vector{Symbol}}, s::String)
    rex = r"^[^\[]*\[([^\]]+)]$"
    m = match(rex, s)
    toks = split(m.captures[1], ',') 
    out = map(x->Symbol(x[2:end]), toks) #remove the colon
    out
end

end #module
