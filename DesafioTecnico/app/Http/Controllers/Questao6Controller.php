<?php

namespace App\Http\Controllers;

class Questao6Controller extends Controller
{
    public function gerarMatrizSudoku()
    {   
        $a = array();
        //define o fator de começo como um número aleatorio de 1 a 9
        $fator = rand(1,9);
        $fator = $this->start($fator);
        //percorre a matriz
        for ($i = 0; $i < 9; $i++) {
            $anterior = $fator;
            for ($j = 0; $j < 9; $j++) {
                if ($j == 0) {
                    $a[$i][$j] = $anterior;
                } else {
                    if($j==3 || $j == 6){
                        if ($anterior > 5) {
                            $anterior = $anterior + 4;
                            $anterior = $anterior - 9; 
                            $a[$i][$j] = $anterior;
                        } else {
                            $a[$i][$j] = $anterior + 4;
                        }
                    }else{
                        if ($anterior > 6) {
                            $anterior = $anterior + 3;
                            $anterior = $anterior - 9; 
                            $a[$i][$j] = $anterior;
                        } else {
                            $a[$i][$j] = $anterior + 3;
                        }
                    }
                

                }
                $anterior = $a[$i][$j];
            }
            if ($fator == 9) {
                $fator = 1;
            } else {
                $fator++;
            }
        }
        //retorna matriz pra view
        return view('questao6', [
            'matriz' => $a,
        ]);
    }
    
    private function start($numero)
    {
        $valor = $numero - 4;
        if ($valor == 0) {
            $valor = 9;
        }
        if ($valor < 0) {
            $valor = 9 + $valor;
        }
        return $valor;
    }

}
