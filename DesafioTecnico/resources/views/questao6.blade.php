<html>
<head>
</head>

<body>

    @for($i=0;$i<9;$i++)
        @if($i==3)
        ________________<br>
         @endif
        @if($i==6)
        ________________<br>
        @endif
        | 
        @for($j=0;$j<9;$j++)
            {{$matriz[$i][$j]}}
            @if($j==2)
            |
            @endif
            @if($j==5)
            |
            @endif
        @endfor

        |         
        <br>
    @endfor
    
</body>

</html>