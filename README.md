# cs193p
Contains coursework completed for Stanford's 2020 CS193p course

Originally, the four apps here lived in their own repos. In 2020, I combined them into this single repository so as to declutter my GitHub, though I was less proficient at Git at that point, so I did not keep the Git history of the initial projects. Nothing to be done now, I suppose.

## Memorize
This is the classic card-matching game. It includes a point-scoring mechanic, customizable themes, and animations for various actions, including:

- Flipping cards along the long edge;
- Spinning emojis when making a match;
- Shrinking cards after completing a match; and
- Shuffling cards at the start of a new game.

#### Playing the game
./demos/Memorize_playing.mov

#### Creating a new theme
./demos/Memorize_editing.mov

## Set Game
[SET](https://en.wikipedia.org/wiki/Set_(card_game)) is a card game requiring visualization, logical reasoning skills, and focus. Furthermore,

> The deck consists of 81 unique cards that vary in four features across three possibilities for each kind of feature: number of shapes (one, two, or three), shape (diamond, squiggle, oval), shading (solid, striped, or open), and color (red, green, or purple). Each possible combination of features (e.g., a card with three striped green diamonds) appears as a card precisely once in the deck.<br><br>In the game, certain combinations of three cards are said to make up a set. For each one of the four categories of features — color, number, shape, and shading — the three cards must display that feature as either a) all the same, or b) all different. Put another way: For each feature the three cards must avoid having two cards showing one version of the feature and the remaining card showing a different version.

This version allows players to deal three cards and/or restart the game at will. Card selections, matches, and deals are all animated.

#### Playing the game
./demos/Set.mov

#### Dealing every card in the game
<img src="https://user-images.githubusercontent.com/8823138/219978389-73155c26-b6b9-4550-988e-864c0b46abd2.PNG" width=250 />

## EmojiArt
This one allows the user to place and resize emojis on a canvas. Emojis can be grouped into user-customizable palettes. The user can add images, too, by taking or uploading pictures or by pasting from the keyboard. Canvases ("Documents") are stored within the user's CoreData and thus persist.

#### Customizing an emoji palette
<img src="https://user-images.githubusercontent.com/8823138/219978787-056acbba-c881-4011-98ca-724119f5d30f.PNG" width=250 />

#### Adding emojis
<img src="https://user-images.githubusercontent.com/8823138/219978824-59ac7248-b072-4376-8fc3-59c5c122751f.PNG" width=250 />

#### Resizing emojis
<img src="https://user-images.githubusercontent.com/8823138/219978834-d824ab8a-4330-44de-8868-cdcab1c6abb6.PNG" width=250 />

#### Working within a document on an iPad
<img src="https://user-images.githubusercontent.com/8823138/219978838-d12bc834-88c0-4f99-a327-df4b664a8f2a.jpeg" width=500 />

## Enroute
Finally, this one allows the user to find and filter flights to/from selected airports. Data is pulled real-time from live flight information.

./demos/Enroute.mov
