### Dockerを用いたStyleGAN2, 3の実行環境構築

### 作成経緯
[StyleGAN3](https://github.com/NVlabs/stylegan3)に公開されているDockerfileをもとに、Docker Composeを使用してより使いやすいDocker環境を構築しました

## 環境構築手順

1. サーバー(PC)にGit, Docker, docker-compose, CUDAをインストール

2. サーバーのホームディレクトリ上にNVlabs/stylegan3をclone

    ```
    git clone https://github.com/NVlabs/stylegan3.git
    ```

3. stylegan3ディレクトリが作成されるので、cdコマンドでそのディレクトリに移動する

    ```
    cd stylegan3
    ```

4. このリポジトリの`Dockerfile`, `.env`, `docker-compose.yml`をstylegan3のディレクトリに上書き保存する

5. 現在ログイン中のIDなどを`.env`に書き込む
    
    - 以下のコマンドでuser_name, uid, gidを調べる
    
        ```
        id
        ```
        
        出力例
        ```
        uid=9999(user_name) gid=9999(group_name) groups=9999(group_name)
        ```

    - `.env`に先ほど調べたuser_name, uid, gidを記述

        ```
        USER_NAME=user_name
        USER_UID=9999
        USER_GID=9999
        ```
        
    > **注意**: 
    > `.env`にuser_name, uid, gidを正確に記入しなければ、コンテナの外部からファイルの削除などの操作が難しくなります

6. 以下のコマンドでDockerのコンテナをビルドする
    
    ```
    docker compose up -d --build
    ```
    
7. 以下のコマンドでDockerのコンテナ環境に入る

    ```
    docker exec -it fake_image_generate bash
    ```

8. StyleGAN2, 3のデータセット作成

    - 学習に使用する画像のあるフォルダを`dataset_image`にリネームする

    ```
    python dataset_tool.py --source=/dataset_image --dest=/datasets/train256x256 \
    --resolution=256x256
    ```

    - `--source=/dataset_image`: 整形するデータセットのファルダを指定する
    
    - `--dest=/datasets/train256x256`: 整形後のデータセットを指定したフォルダに保存する
    
    - `--resolution=256x256`: --destの解像度を設定する。ただし解像度は2のn乗(16, 32, 64, 128, etc...)のみ設定できる

9. StyleGAN2, 3のトレーニング

    #### StyleGAN3の場合
    
    ```
    python train.py --outdir=/training-runs --cfg=stylegan3-t --data=/datasets/train256x256 \
    --gpus=1 --batch=32 --gamma=2 --mirror=1
    ```

    - `--outdir=/training-runs`: モデルを保存するディレクトリを指定する
    
    - `--cfg=stylegan3-t`: 使用するモデルを指定する
    
    - `--gpus=1`: 使用するgpuの数を指定する
    
    - `--batch=32`: batchサイズを指定する
    
    - `--gamma=2`: 正則化の強さを指定する
    
    - `--mirror=1`: 画像を左右反転させるデータ拡張を行う
    
    #### StyleGAN2の場合
    
    ```
    python train.py --outdir=/training-runs --cfg=stylegan2 --data=/datasets/train256x256 \
    --gpus=1 --batch=16 --gamma=0.8192 --map-depth=2 --glr=0.0025 --dlr=0.0025 --cbase=16384
    ```
    
    オプションの意味:
    
    - `--map-depth=2`: Mapping networkの深さを2に設定する
    
    - `--glr=0.0025`: 生成器の学習率を0.0025に設定する
    
    - `--dlr=0.0025`: 識別器の学習率を0.0025に設定する
    
    - `cbase=16384`: 生成モデルのサイズを小さくすることで、トレーニングを高速化する
    
    トレーニングのコツ: fid50kのスコアが下がらなくなった場合、すぐにトレーニングを終了してください
    
    より詳細な設定は[Training configurations](https://github.com/NVlabs/stylegan3/blob/main/docs/configs.md)を確認してください
    
    
10. StyleGAN2, 3で偽画像を生成する

    ```
    python gen_images.py --outdir=fake_output --trunc=1 --seeds=0-16 \
    --network=./training_run/00000-stylegan2-train256-gpus1-batch32-gamma0.4096/network-snapshot-001800.pkl
    ```
    
    オプションの意味:  
    
    - `--outdir=fake_output`: 生成した偽画像を保存するフォルダを指定する
    
    - `--trunc=1`: [qiita](https://qiita.com/Phoeboooo/items/12d21916de56d125f0be)に詳しい解説がありますので、参考にしながら設定してください
    
    - `--seed=0-16`: seedを用いて偽画像を16枚生成する。--seed=0-50とすることで、50枚偽画像を生成できる
    
    - `--network=`: training_runフォルダに保存されているpklファイルを指定する
    
    > **注意**: 
    > 白黒の偽画像を生成したい場合は、[gen_images.pyの136, 137行目を変更する](https://github.com/NVlabs/stylegan3/issues/211)必要があるかもしれません

## ライセンス(StyleGAN2, 3)
StyleGAN2, 3のライセンスについては[StyleGAN3のGitHubページ](https://github.com/NVlabs/stylegan3/)で確認してください

## 参考文献

- [StyleGAN3のGitHubページ](https://github.com/NVlabs/stylegan3/)

- [医療画像の生成はStyleGAN2でないとうまくいかないというissue](https://github.com/NVlabs/stylegan3/issues/77)

- [エラー：raise Value Error: not enough image dataの解決策](https://github.com/NVlabs/stylegan3/issues/211)
