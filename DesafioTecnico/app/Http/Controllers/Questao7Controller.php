<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use \Exception;

require "simple_html_dom.php";


class Questao7Controller extends Controller
{
    public function informacoesVeiculos(Request $request)
    {
        $dados = $request->all();

        try {

            if (!isset($dados["marca"])) {
                throw new Exception('informar marca do veiculo');
            }else{
                $marca = $dados["marca"];
            } 
            if (!isset($dados["modelo"])) {
                throw new Exception('informar modelo do veiculo');
            }else{
                $modelo = $dados["modelo"];
            }
            if (!isset($dados["ano"])) {
                throw new Exception('informar ano do veiculo');
            }else{
                $anoF = $dados["ano"];
            }
            
            $veiuculos = array();
            $url = "https://www.seminovos.com.br/carro/$marca/$modelo/ano-$anoF-";
            $html = file_get_html($url);

            //modelo
            preg_match_all('/<h2 class="card-title">(.*?)<\/h2>/', $html, $match);
            foreach ($match[1] as $k => $valor) {
                $veiuculos[$k]["Modelo"] = $valor;
            }
            //valor
            preg_match_all('/<span class="card-price">(.*?)<\/span>/', $html, $match);
            foreach ($match[1] as $k => $valor) {
                $veiuculos[$k]["Preco"] = $valor;
            }

            preg_match_all('/<div class="card-info">(.*?)<\/div>/', $html, $match);
            foreach ($match[0] as $k => $carro) {
                //versao do carro
                preg_match_all('/<p class="card-subtitle">(.*?)<\/p>/', $carro, $versao);
                $replace = array('<p class="card-subtitle">', "</p>", "<span>", " ");
                $versao = str_replace($replace, "", $versao[0][0]);
                //fabricacao
                preg_match_all('/<li title="Ano de fabricação">(.*?)<\/li>/', $carro, $ano);
                $replace = array('<i', 'class="icon', "<span>", "  ", 'icon-calendar"></i>');
                $ano = str_replace($replace, "", $ano[1][0]);
                //Quilometragem
                preg_match_all('/<li title="Kilometragem atual">(.*?)<\/li>/', $carro, $km);
                $replace = array('<i', 'class="icon', "<span>", "  ", 'icon-velocity"></i>');
                $km = str_replace($replace, "", $km[1][0]);
                //adicionais
                preg_match_all('/<ul class="list-inline">(.*?)<\/ul>/', $carro, $adicionais);
                $replace = array('<p class="card-subtitle">', "</p>", "<span>", "", "<li>", "</li>", "  ", "</span>");
                $adicionais = str_replace($replace, "", $adicionais[1][0]);

                $veiuculos[$k]["Versao"] = $versao;
                $veiuculos[$k]["Ano Fabricacao"] = $ano;
                $veiuculos[$k]["Quilometragem"] = $km;
                $veiuculos[$k]["Extras"] = $adicionais;
            }

        } catch (Exception $e) {
            return ["erro"=>$e->getMessage()];
        }
        $retorno["Url Origem da SemiNovos"] = $url;
        $retorno["resposta"] =  $veiuculos;
        return $retorno;
    }
}
