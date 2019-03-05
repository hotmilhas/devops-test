<?php

namespace App\Http\Controllers;

class Questao3Controller extends Controller
{
    public function estacionamento()
    {
        $estacionamento = new Estacionamento(3);
        echo "<pre>";
        $estacionamento->relatorioEstacionamento();
        $estacionamento->adicionaNovoCarro();

        $estacionamento->abrirEstacionamento();

        $estacionamento->adicionaNovoCarro();
        $estacionamento->adicionaNovoCarro();
        $estacionamento->adicionaNovoCarro();
        $estacionamento->adicionaNovoCarro();

        $estacionamento->relatorioEstacionamento();

        $estacionamento->retiraCarro();
        $estacionamento->retiraCarro();

        $estacionamento->relatorioEstacionamento();

        $estacionamento->retiraCarro();
        $estacionamento->retiraCarro();

        $estacionamento->relatorioEstacionamento();

        $estacionamento->adicionaNovoCarro();
        $estacionamento->fecharEstacionamento();
        $estacionamento->retiraCarro();

        $estacionamento->relatorioEstacionamento();
    }
}

class Estacionamento
{
    private $portao;
    private $vagasTotais;
    private $guarita;
    private $manobrista;

    public function __construct($vagasTotais)
    {
        $this->portao = false;
        $this->manobrista = new Manobrista();
        $this->vagasTotais = $vagasTotais;
        $this->guarita = new Guarita();
    }

    public function adicionaNovoCarro()
    {
        $lotacao = $this->guarita->relatorioGuarita();
        if ($this->portao) {
            if ($lotacao < $this->vagasTotais) {
                if (!$this->manobrista->getStatusManobrista()) {
                    $this->manobrista->manobrar();
                    $this->guarita->entrarCarro();
                    $this->manobrista->finalizarManobra();
                    echo " carro adicionado";
                } else {
                    echo " Nenhum manobrista disponível";
                }
            } else {
                echo " Sem vagas disponíveis";
            }
        } else {
            echo " Estacionamento fechado";
        }
        echo "<br>";
    }

    public function retiraCarro()
    {
        $lotacao = $this->guarita->relatorioGuarita();
        if ($this->portao) {
            if ($lotacao > 0) {
                if (!$this->manobrista->getStatusManobrista()) {
                    $this->manobrista->manobrar();
                    $this->guarita->sairCarro();
                    $this->manobrista->finalizarManobra();
                    echo " carro retirado";
                } else {
                    echo " Nenhum manobrista disponível";
                }
            } else {
                echo " Não existem carros para serem retirados";
            }
        } else {
            echo " Estacionamento fechado";
        }
        echo "<br>";
    }

    public function abrirEstacionamento()
    {
        $this->portao = true;
    }
    public function fecharEstacionamento()
    {
        $this->portao = false;
    }

    public function relatorioEstacionamento()
    {
        echo " Vagas Totais -> " . $this->vagasTotais;
        echo " Vagas Ocupadas -> " . $this->guarita->relatorioGuarita();
        if ($this->manobrista->getStatusManobrista()) {
            echo " Manobrista -> Ocupado";
        } else {
            echo " Manobrista -> Disponivel";
        }
        echo "<br>";
    }
}

class Manobrista
{
    private $manobrando;

    public function __construct()
    {
        $this->manobrando = false;
    }

    public function manobrar()
    {
        $this->manobrando = true;
    }

    public function finalizarManobra()
    {
        $this->manobrando = false;
    }

    public function getStatusManobrista()
    {
        return $this->manobrando;
    }

}

class Guarda
{
    private $cassetete;
    private $listaDeCarros;

    public function __construct()
    {
        $this->cassetete = true;
        $this->listaDeCarros = 0;
    }

    public function adicionaCarroLista()
    {
        $this->listaDeCarros++;
    }

    public function removeCarroLista()
    {
        $this->listaDeCarros--;
    }

    public function getListaDeCarros()
    {
        return $this->listaDeCarros;
    }

}

class Guarita
{
    private $guarda;
    private $catraca;

    public function __construct()
    {
        $this->guarda = new Guarda();
        $this->catraca = false;
    }

    public function entrarCarro()
    {
        $this->catraca = true;
        $this->guarda->adicionaCarroLista();
        $this->catraca = false;
    }

    public function sairCarro()
    {
        $this->catraca = true;
        $this->guarda->removeCarroLista();
        $this->catraca = false;
    }

    public function relatorioGuarita()
    {
        return $this->guarda->getListaDeCarros();
    }

}
