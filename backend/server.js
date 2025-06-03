const espress = require('express');
const cors = require('cors');
0
const app = espress();
const port = 3000;

app.use(cors());
app.use(espress.json());

let animais = [];
let proximoAnimal = 1;

app.post('/animais', (req, res) => {
    const {
        nomeTutor,
        contatoTutor,
        especie,
        raca,
        dataEntrada,
        previsaoDataSaida
    } = req.body;

    if (!nomeTutor || !contatoTutor || !especie || !raca || !dataEntrada) {
        return res.status(400).json({ message: 'Preencha todos os campos Obricatótios.' });
    }

    const novoAnimal = {
        id: proximoAnimal++,
        nomeTutor,
        contatoTutor,
        especie,
        raca,
        dataEntrada,
        previsaoDataSaida
    }

    animais.push(novoAnimal);
    res.status(201).json(novoAnimal);
});

function calcularDias(dataInicius, dataFim) {
    const umDia = 24 * 60 * 60 * 1000;
    const d1 = new Date(dataInicius);
    const d2 = new Date(dataFim);
    const d1UTC = Date.UTC(d1.getFullYear(), d1.getMonth(), d1.getDate());
    const d2UTC = Date.UTC(d2.getFullYear(), d2.getMonth(), d2.getDate());
    return Math.floor((d2UTC - d1UTC) / umDia);
}

app.get('/animais', (req, res) => {
    const hoje = new Date();
    
    const animaisComCalculo = animais.map(animal => {
        const dataEntradaDate = new Date(animal.dataEntrada);
        let diariasAteHoje = 0;
        let diariasPrevista = null;

        diariasAteHoje = calcularDias(dataEntradaDate, hoje) + 1;
        if(diariasAteHoje < 1) diariasAteHoje = 1;

        if(animal.previsaoDataSaida){
            const previsaoSaidaDate = new Date(animal.previsaoDataSaida);

            diariasPrevista = calcularDias(dataEntradaDate, previsaoSaidaDate) + 1;
            if(diariasPrevista < 1) diariasPrevista=1;
        }
        return{
            ...animal,
            diariasAteHoje,
            diariasPrevista
        }
    })
    res.status(200).json(animaisComCalculo);
})

app.get('/animais/:id', (req, res) => {
    const idAnimal = parseInt(req.params.id);
    const animal = animais.find(a => a.id === idAnimal);

    if(!animal){
        return res.status(400).json({message: 'Animal não encontrado.'});
    }
    const hoje = new Date();
    const dataEntradaDate =new Date(animal.dataEntrada);
    let diariasAteHoje = calcularDias(dataEntradaDate, hoje) +1;
    if(diariasAteHoje <1) diariasAteHoje = 1;

    let diariasPrevista = null;
    if(animal.previsaoDataSaida){
        const previsaoSaidaDate = new Date(animal.previsaoDataSaida);
        diariasPrevista = calcularDias(dataEntradaDate, previsaoSaidaDate)+1;
        if(diariasPrevista <1) diariasPrevista =1;
    }
    res.status(200).json({
        ...animal,
        diariasAteHoje,
        diariasPrevista
    })
})

app.put('/animais/:id', (req, res) => {
    const idAnimal = parseInt(req.params.id);
    const indexAnimal = animais.findIndex(a => a.id === idAnimal);

    if(indexAnimal === -1){
        return res.status(400).json({ message: 'Animal não encontrato.'});
    }

    const{
        nomeTutor,
        contatoTutor,
        especie,
        raca,
        dataEntrada,
        previsaoDataSaida
    } = req.body;

    animais[indexAnimal] ={
        ...animais[indexAnimal],
        nomeTutor: nomeTutor || animais[indexAnimal].nomeTutor,
        contatoTutor: contatoTutor || animais[indexAnimal].contatoTutor,
        especie: especie || animais[indexAnimal].especie,
        raca: raca || animais[indexAnimal].raca,
        dataEntrada: dataEntrada || animais[indexAnimal].dataEntrada,
        previsaoDataSaida: previsaoDataSaida !== undefined ? previsaoDataSaida : animais[indexAnimal].previsaoDataSaida
    }
    res.status(200).json(animais[indexAnimal]);
})

app.delete('/animais/:id', (req, res)=> {
    const idAnimal = parseInt(req.params.id);
    const indexAnimal = animais.findIndex(a => a.id === idAnimal);

    if(indexAnimal === -1){
        return res.status(404).json({message: 'Animal não encontrado'});
    }

    animais.splice(indexAnimal, 1);
    res.status(204).send();
})

app.listen(port, () => {
    console.log('Servidor Hotel Pet rodanod em http://localhost:3000/animais');
})