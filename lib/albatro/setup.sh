#!/bin/sh
# ./albatro --study="アヒルと鴨のコインロッカー" --trace --no-rescue_silent --say="アヒル"
# ./albatro --database yoshinoya.db --load --info --response 大森 8
# ./albatro --database yoshinoya.db --load --info --response 大森 8
# ./albatro --database sweets.db --uniquesuffix --read sweets.txt --count 100
exit

./albatro --database yoshinoya.db --uniquesuffix --read yoshinoya_2ch.txt --save
./albatro --database yoshinoya.db --uniquesuffix                      --load
./albatro --database yoshinoya.db --uniquesuffix --read yoshinoya_2ch.txt --read yoshinoya_2ch.txt --info
./albatro --database yoshinoya.db --uniquesuffix --read yoshinoya_2ch.txt --tree

# ./albatro --uniquesuffix  --study="アヒルと鴨" --study="アヒルと鴨" --tree --dump
# ./albatro --uniquesuffix    --study="アヒルと鴨" --study="アヒルと鴨" --tree --dump
# ./albatro --no-uniquesuffix --study="アヒルと鴨の" --study="アヒルと鴨の" --dump
# ./albatro --study="私が速い" --study="私が速い" --tree
# ./albatro --study="私は速い虫だ" --study="私が速い魚だ" --study="私が速い虫よ" --tree
# ./albatro --study="秋刀魚の季節" --study="秋刀魚の季節" --tree --dump
