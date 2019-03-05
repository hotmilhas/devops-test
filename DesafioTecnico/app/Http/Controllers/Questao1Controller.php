<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use \Exception;

class Questao1Controller extends Controller
{
    
    public function solucaoFuncaoSegundoGrau(Request $request){
        //pega os dados vindos da requisicao
        $dados = $request->all();
        
        try{  
            //realiza algumas validacoes
            if(isset($dados["a"])){
                if(is_numeric($dados["a"])){
                    $a = (int)$dados["a"];
                    if($a == 0){
                        throw new Exception('Parametro A precisa ser diferente de 0');
                    }
                }else{
                    throw new Exception('Parametro A precisa ser um numero');
                }
            }else{
                throw new Exception('Parametro A precisa ser enviado');
            }
            if(isset($dados["b"])){
                if(is_numeric($dados["b"])){
                    $b = (int)$dados["b"];
                }else{
                    throw new Exception('Parametro B precisa ser um numero');
                }
            }else{
                $b = 0;
            }
            if(isset($dados["c"])){
                if(is_numeric($dados["c"])){
                    $c = (int)$dados["c"];
                }else{
                    throw new Exception('Parametro C precisa ser um numero');
                }
            }else{
                $c = 0;
            }

            //faz os cauculos
            $delta = ($b*$b)-(4*$a*$c);
            if($delta<0){
                $retorno = "Sem raizes reais";
            }else{
                $x1 = ((-1*$b)+sqrt($delta))/($a*2);
                $x2 = ((-1*$b)-sqrt($delta))/($a*2);
                
                $retorno = [
                    "x1" => round($x1,2),
                    "x2" => round($x2,2)
                ];
            }
          return $retorno;
        }catch(Exception $e){
            return $e->getMEssage();
        }
        
    }
}
