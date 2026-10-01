<p align="right"><a href="README.md">🇺🇸 English</a></p>

# Guia de Conversão de Áudio com FFmpeg
**Última atualização:** 01/10/2026

Este guia fornece instruções passo a passo para converter arquivos de áudio, com foco especial na transição de FLAC para MP3 preservando a máxima qualidade e metadados.

A documentação oficial do FFmpeg se encontra em: [https://ffmpeg.org/ffmpeg.html](https://ffmpeg.org/ffmpeg.html).

Também incluo uma breve seção sobre o programa [MusicBrainz Picard](https://picard.musicbrainz.org/), o qual uso para obter os metadados completos das músicas e álbuns, que busca de um banco de dados de discos lançados oficialmente, possuindo dados de várias versões (releases) dos álbuns.

Outra alternativa para converter arquivos de áudio é o software [Foobar2000](https://www.foobar2000.org/), que possui interface gráfica e é um dos players mais antigos e completos da internet.

---

## 1. Instalação do FFmpeg

A maneira mais fácil de instalar é pelo winget do Windows (para usuários do Windows), já que o site oficial (https://ffmpeg.org/) só disponibiliza os binários, e você teria que configurar o PATH manualmente.

Abra o PowerShell:
```powershell
winget install ffmpeg
```

Após instalar, se o terminal não reconhecer o ffmpeg, atualize o PATH manualmente:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

---

## Converter pasta inteira de FLAC para MP3

### Qualidade V0 (Variável - Alta Qualidade - recomendado)
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### 320 kbps (máxima qualidade MP3)
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -b:a 320k -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### 256 kbps ou outros formatos
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -b:a 256k -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### Conversão com Verificação e Log (Seguro para deletar FLAC)
Para quem deseja automatizar a verificação de integridade e ter um relatório final antes de apagar os originais, o ideal é utilizar um script do PowerShell com extensão `.ps1`. 

Exemplo de lógica básica para rodar no terminal:
```powershell
# Exemplo simplificado para rodar no terminal (gera log básico)
$sucessos = 0; $erros = 0
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    $out = "$($_.DirectoryName)\$($_.BaseName).mp3"
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 $out 2>$null
    if ($LASTEXITCODE -eq 0) { $sucessos++ } else { $erros++ }
}
Write-Host "Convertidos: $sucessos | Falhas: $erros"
```

> Navegue até a pasta dos FLACs antes de rodar: `cd "C:\caminho\da\pasta"`

---

## Resumo dos principais comandos FFmpeg

### Conversão básica
```powershell
ffmpeg -i entrada.flac saida.mp3
```

### Conversão com bitrate específico
```powershell
ffmpeg -i entrada.flac -b:a 256k saida.mp3
```

### Conversão preservando metadados (tags, capa)
```powershell
ffmpeg -i entrada.flac -b:a 256k -map_metadata 0 saida.mp3
```

### Converter para outros formatos
```powershell
ffmpeg -i entrada.flac saida.ogg
ffmpeg -i entrada.mp3 saida.wav
ffmpeg -i entrada.flac saida.aac
```

### Ver informações do arquivo de áudio
```powershell
ffmpeg -i arquivo.flac
```

### Cortar áudio (de 00:01:00 até 00:03:30)
```powershell
ffmpeg -i entrada.mp3 -ss 00:01:00 -to 00:03:30 saida.mp3
```

### Cortar áudio por duração (começa no segundo 60, dura 90 segundos)
```powershell
ffmpeg -i entrada.mp3 -ss 60 -t 90 saida.mp3
```

### Normalizar volume
```powershell
ffmpeg -i entrada.mp3 -filter:a loudnorm saida.mp3
```

### Extrair áudio de vídeo
```powershell
ffmpeg -i video.mp4 -vn -b:a 256k audio.mp3
```

### Converter vários arquivos em lote (pasta inteira)
```powershell
Get-ChildItem -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

### Converter pasta específica
```powershell
Get-ChildItem -Path "C:\caminho\da\pasta" -Filter "*.flac" | ForEach-Object {
    ffmpeg -i $_.FullName -q:a 0 -map_metadata 0 "$($_.DirectoryName)\$($_.BaseName).mp3"
}
```

---

## Tabela de qualidade MP3

| kbps / Tipo | Qualidade |
|------|-----------|
| V0 | Máxima (Variável), a melhor relação fidelidade/tamanho |
| 320  | Máxima (Constante), indistinguível do FLAC para a maioria |
| 256  | Muito boa, arquivo menor |
| 192  | Boa, tamanho equilibrado |
| 128  | Aceitável, arquivos pequenos |

---

## Criação e Execução de Scripts (.ps1)

Quando os comandos ficam muito longos ou exigem verificações complexas (como comparar a duração do MP3 com a do FLAC), a melhor prática é criar um script do PowerShell.

### 1. Como criar o script
1. Abra o VS Code.
2. Escolha um dos modelos abaixo (conforme sua necessidade) e crie o arquivo com a extensão `.ps1`.
3. **Importante**: Abra o arquivo e edite a variável `$root = 'D:\Music'` para o caminho da sua pasta de músicas.

#### Modelos Disponíveis

Os scripts estão na pasta `/scripts` deste repositório. Você pode baixá-los ou copiar o conteúdo e colar em qualquer editor de texto, salvando com a extensão `.ps1`.

- **`QuickConvert.ps1`**: Conversão direta e rápida. Ideal para quem confia plenamente nos arquivos.
- **`SafeConvert.ps1`**: Utiliza arquivos temporários (`.tmp`). Só renomeia para `.mp3` se a conversão for concluída sem erros.
- **`AuditConvert.ps1`**: O nível máximo de segurança. Faz inventário de tamanho, usa o `ffprobe` para validar se o áudio interno do MP3 é real e funcional antes de dar o OK.

**Dica de Uso**: Você pode colocar o script dentro da pasta de músicas. Se quiser isso, altere a linha: `$root = 'D:\Music'` para:
```powershell
$root = $PSScriptRoot
```
Assim, o script converterá automaticamente todos os FLACs da pasta onde ele estiver e de todas as subpastas.

> Os scripts estão configurados com o argumento `-q:a 0`, que converte na máxima qualidade com bitrate variável.

### 2. Como executar o script

Por padrão, o Windows bloqueia a execução de scripts por segurança. Para rodar seu script:

**Opção A: Executar via Terminal do VS Code**
```powershell
.\AuditConvert.ps1
```

*Se der erro de "Execution Policy", antes de executar o script, rode:*
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
E confirme, para liberar o usuário para rodar scripts no PowerShell.

**Opção B: Executar via PowerShell (Admin)**
1. Abra o PowerShell como Administrador.
2. Navegue até a pasta: `cd "C:\caminho\do\script"`
3. Execute: `.\AuditConvert.ps1`

---

## Técnicas Avançadas de Segurança e Validação

Para quem deseja um nível de precisão profissional (estilo servidor), existem três técnicas que garantem que nenhum arquivo seja perdido ou corrompido:

### 1. Conversão via Arquivo Temporário (`.tmp`)
Em vez de converter diretamente para `.mp3`, o script converte para `.mp3.tmp`. 
- **Por que?** Se a conversão falhar no meio, você terá um arquivo `.tmp` incompleto, mas não terá um arquivo `.mp3` "falso" que enganaria o sistema.
- **Fluxo**: `FLAC` → `MP3.tmp` → (Validação OK?) → `MP3`

### 2. Detecção de Conflitos Prévios
Antes de iniciar, é possível rodar um inventário para mapear quais FLACs já possuem um MP3 correspondente. Isso evita processamento desnecessário e permite criar uma lista de "arquivos a ignorar".

### 3. Validação Técnica com `ffprobe`
O `ffprobe` (irmão do ffmpeg) consegue ler a "anatomia" do arquivo. Para garantir que o MP3 é válido, podemos checar:
- **Codec**: Confirmar se é `mp3`.
- **Duração**: Verificar se a duração é maior que zero.
- **Bitrate**: Validar se o bitrate está dentro da faixa esperada (ex: entre 300kbps e 330kbps para MP3 320k).

---

## Edição e Busca de Metadados (MusicBrainz Picard)

Para organizar a biblioteca após a conversão, o **MusicBrainz Picard** é a ferramenta recomendada para buscar metadados precisos e renomear arquivos automaticamente.

Você pode baixá-lo no site oficial: [https://picard.musicbrainz.org/](https://picard.musicbrainz.org/)

### Configuração do File Naming Script
Para evitar a colisão de nomes em álbuns com múltiplos discos e manter a organização limpa, você pode configurar o **File naming script editor** com o seguinte comando:

```text
$if2(%albumartist%,%artist%)-$if($gt(%totaldiscs%,1),%discnumber%-)$num(%tracknumber%,2)-%title%
```

### O que isso faz:
- **Álbuns com múltiplos discos** (`%totaldiscs%` > 1): Adiciona o número do disco antes da faixa.
  - *Resultado:* `Eisbrecher-1-01-Eisbär.mp3`, `Eisbrecher-2-01-Schwarze Witwe (2018).mp3`
- **Álbuns de disco único**: Mantém o formato simples, sem adicionar o número do disco.
  - *Resultado:* `Eisbrecher-01-Polarstern.mp3`

**Como aplicar:** Cole o script no editor de renomeação do Picard e clique em **"Faça assim!"** para aplicar as alterações aos arquivos selecionados.

---

## Utilizando o Foobar2000

Como alternativa ao FFmpeg (que não possui interface gráfica e pode ser uma barreira para usuários leigos em terminal), você pode usar o Foobar2000, baixado em [https://www.foobar2000.org/](https://www.foobar2000.org/).

O **foobar2000** é amplamente considerado um dos melhores conversores de áudio para Windows, sendo muito prático para converter lotes de FLAC para MP3 (seja em V0 ou 320 kbps) sem precisar mexer em linhas de comando.

Como o foobar2000 precisa do executável oficial do codificador MP3 do LAME para realizar conversões com perfis avançados (como o V0), o processo envolve uma configuração inicial rápida e depois uma rotina de conversão muito simples.

### Passo 1: Preparação Inicial (Baixar o conversor LAME)

O foobar2000 por si só não converte para MP3 nativamente sem o arquivo oficial do LAME por questões de patente.

1. Baixe o **Encoder Pack** oficial no site do foobar2000 (`foobar2000.org` na seção de componentes) ou baixe diretamente o arquivo `lame.exe`.

2. Extraia o `lame.exe` em uma pasta de fácil acesso no seu computador (por exemplo, `C:\Tools\lame.exe`).

### Passo 2: Criando a sua Rotina (Guia passo a passo) no foobar2000

Uma vez configurado, para converter os seus FLACs em lote, siga este roteiro:

#### 1. Importar os arquivos

- Abra o **foobar2000**.
- Arraste a pasta ou os arquivos `.flac` que você deseja converter diretamente para dentro da janela principal do programa.

#### 2. Selecionar e acionar a conversão

- Selecione todas as músicas na lista (pressione `Ctrl + A`).
- Clique com o botão direito em cima das músicas selecionadas.
- Vá em **Convert** (Converter) > **... (Quick Convert)** ou **Convert** > **Fazer conversão**.

#### 3. Configurar o Perfil de Saída (MP3 V0 ou 320 kbps)

Na janela de configuração que vai se abrir, escolha o formato de saída:

- Clique em **Output format** (Formato de saída).
- Selecione **MP3 (lame)**.
- Ajuste o modo de qualidade conforme a sua preferência:
  - **Para a qualidade V0 (VBR):** Escolha o modo _VBR_ e mova o controle deslizante para a qualidade máxima (equivalente ao preset V0, geralmente gerando taxas dinâmicas em torno de 245 kbps).
  - **Para 320 kbps (CBR):** Escolha o modo _CBR_ e defina o valor fixo para **320 kbps**.
- Clique em **Back** (Voltar).

#### 4. Indicar onde o LAME está (Apenas na primeira vez)

- Se o foobar2000 perguntar onde está localizado o arquivo **`lame.exe`**, navegue até a pasta onde você o salvou no Passo 1 (`C:\Tools\lame.exe`) e selecione-o. O programa memoriza esse caminho para sempre.

#### 5. Definir o destino e converter

- Em **Destination** (Destino), escolha se deseja salvar os MP3s na mesma pasta dos arquivos originais ou em uma pasta separada.
- Clique no botão **Convert** (Converter).

### Como criar Predefinições (Presets)

Para criar **predefinições (presets)** no foobar2000 — permitindo alternar com um clique entre o perfil **MP3 V0** e **MP3 320 kbps** sem ter que reconfigurar tudo de novo —, você utiliza a ferramenta **Converter Setup**.

Siga este roteiro passo a passo:

#### Passo 1: Abrir o Conversor e Configurar o primeiro Preset (ex: MP3 V0)

1. No foobar2000, selecione algumas músicas na lista, clique com o botão direito e vá em **Convert** > **... (Quick Convert)** (ou _Fazer conversão_).

2. Na janela que se abre, clique em **Output format** (Formato de saída), selecione **MP3 (lame)** e configure os parâmetros para **V0** (modo VBR na qualidade máxima).

3. Ajuste também as outras opções que você deseja que fiquem salvas nesse perfil (por exemplo: padrão de nomeação de arquivos em _Destination_ ou tratamento de capas de álbum).

4. No topo dessa mesma janela de configuração, procure pelo botão **Save** (Salvar) ou **Save preset** (Salvar predefinição).

5. Dê um nome claro para ele, como por exemplo: **`MP3 - V0 VBR`** e salve.

#### Passo 2: Criar o segundo Preset (ex: MP3 320 kbps)

1. Ainda na mesma janela, mude o formato de saída (**Output format**) para **MP3 (lame)**, mas agora configure o modo para **CBR** e defina o valor fixo em **320 kbps**.

2. Volte ao topo da janela e clique novamente em **Save** / **Save preset**.

3. Dê um nome para diferenciar, como: **`MP3 - 320kbps CBR`** e salve.

#### Como usar os seus Presets a partir de agora:

Com os presets salvos, você nunca mais precisará reconfigurar as opções de áudio:

1. Selecione os arquivos FLAC que deseja converter.

2. Clique com o botão direito e vá em **Convert** > **Converter (menu completo)** ou no atalho que leva direto aos presets salvos.

3. Você verá uma lista com os seus perfis criados (**`MP3 - V0 VBR`** e **`MP3 - 320kbps CBR`**).

4. Basta clicar em cima do preset desejado e a conversão começará instantaneamente com as configurações prontas!

### Vantagens do foobar2000 em relação ao script do FFmpeg:

- **Metadados e Capas:** Ele copia automaticamente as capas de álbum (`cover.jpg` ou tags embutidas) direto para os arquivos MP3 gerados sem precisar de comandos extras de mapeamento.

- **Interface Gráfica:** Permite visualizar o progresso de conversão de múltiplos arquivos em paralelo de forma muito limpa.
