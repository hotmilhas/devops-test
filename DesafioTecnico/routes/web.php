<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/questao6',"Questao6Controller@gerarMatrizSudoku");
Route::get('/questao3',"Questao3Controller@estacionamento");
Route::get('/questao1',"Questao1Controller@solucaoFuncaoSegundoGrau");

