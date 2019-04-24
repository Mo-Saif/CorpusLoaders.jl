using DataFrames
using CSV

struct Twitter{S}
    data::Array{S}
end

function Twitter(category="train_pos")
    fileMap = Dict("train" => "training.1600000.processed.noemoticon.csv", "test" => "testdata.manual.2009.06.14.csv")
    polarityMap = Dict("pos" => 4, "neg" => 0, "neu" => 2)
    file, polarity = fileMap[split(category, "_")[1]], polarityMap[split(category, "_")[2]]
    path = joinpath(datadep"Twitter Sentiment Dataset", "$file")
    dataframe = CSV.read(path, header=0)
    Twitter(dataframe.Column6[dataframe.Column1 .== polarity])
end

MultiResolutionIterators.levelname_map(::Type{Twitter}) = [
    :document => 1, :tweet => 1,
    :sentences => 2,
    :words => 3, :tokens => 3,
    :charaters => 4
    ]

function load(dataset::Twitter)
    Channel(ctype=@NestedVector(String, 2), csize=4) do docs
        for tweet in dataset.data
            para = [intern.(tokenize(sent)) for sent in split_sentences(tweet)]
            put!(docs, para)
        end
    end
end
