

#verifies whether a given solution/incomplete solution is feasible
function queens_is_valid_configuration(board, roll)
    #heron: why can board be a Number ? In the code, it is always accessed as an array.
    
    for i=2:roll-1
        if (board[i] == board[roll])
            return false
        end
    end

    ld = board[roll]
    rd = board[roll]

    for j=(roll-1):-1:2
        ld -= 1
        rd += 1
        if (board[j] == ld || board[j] == rd)
            return false
        end
    end

    return true
end ##queens_is_valid_conf
