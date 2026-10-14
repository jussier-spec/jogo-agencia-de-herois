const fs = require('fs');

const url = 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json';

async function main() {
  console.log('Baixando os herois...');
  const resposta = await fetch(url);
  if (!resposta.ok) throw new Error('Nao foi possivel baixar o JSON.');
  const herois = await resposta.json();

  const db = { heroes: herois };
  fs.writeFileSync('db.json', JSON.stringify(db, null, 2));
  console.log(`Arquivo db.json criado com ${herois.length} herois.`);
}

main().catch((erro) => {
  console.error(erro);
  process.exit(1);
});
