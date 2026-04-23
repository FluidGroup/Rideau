# Rideau Gesture & Motion Spec

この spec は Rideau の sheet ジェスチャーと inner `UIScrollView` のコーディネーション挙動、
および rubber-band の挙動を定義する。実装はこの spec に従う。

## 1. 用語

- **Sheet** … Rideau が表示しているドロワー本体（`containerView`）。
- **Snap point** … sheet が吸着する位置。`RideauView.Configuration.snapPoints` で宣言され、
  内部で上から順に並んだ `ResolvedSnapPoint` に解決される。
  - **Top snap point** = `resolvedSnapPoints.first`（最も展開された位置）。
  - **Bottom-most visible snap point** = 非 hidden のうち最も低い位置。
  - **Hidden** … sheet が画面外に退避する特殊な snap point。
- **Hiding offset** … sheet 下端の bottom 制約の `constant`。大きいほど sheet は下。
- **Inner scroll view** … sheet コンテンツ内の `UIScrollView`。submodule が responder chain で
  自動検出する（複数ある場合は 1 つのみトラッキング対象）。
- **Outer drag** … sheet 自体を上下させるジェスチャー。
- **`isScrollLockEnabled`** … submodule のフラグ。true の間、submodule は inner scroll view の
  `contentOffset` を KVO で固定し、translation をすべて outer drag に流す。
- **Top edge of scroll view** … `scrollableEdges.contains(.top) == false`
  （いちばん上までスクロールされた状態）。submodule 側で判定される。

## 2. ジェスチャー役割分担

**Rideau 側**：

- 「sheet が現在 top snap にいるか」の判定。
- それに応じて `panGesture.isScrollLockEnabled` をトグル。
- `handleDragChange` / `handleDragEnd` で受け取る translation / velocity から
  snap 遷移とアニメーションを司る。

**Submodule 側**（`edgeActivationMode: .onlyAtGestureStart`, `targetEdges: .top`,
`sticksToEdges: true`, `minimumActivationDistance: 15`）：

- 15pt 未満の jiggle を呑む（Rideau には `onChange` を渡さない）。
- `isScrollLockEnabled == true` の間は inner scroll view を完全ロックして
  translation を全部 outer に渡す。
- `isScrollLockEnabled == false` の間、**gesture 開始時に scroll view が
  target edge にいた時のみ** outer を起動する。mid-content で始まった gesture は、
  その gesture が終わるまで inner scroll view が独占する。
- ロック時に in-flight deceleration をキャンセル。ロック解除時も deferred で再キャンセル。
- ロック中は scroll indicator を隠し、gesture 終了時に元に戻す。

## 3. ジェスチャー＆モーション規則

### 3.1 Gesture 開始時に top **以外**の snap にいたとき

- Rideau は `isScrollLockEnabled = true` に設定（以降 gesture 中 true を維持）。
- 上方向ドラッグ → sheet が上に動く。
- 下方向ドラッグ → sheet が下に動く（下の snap / hidden へ向かう）。
- この gesture 中に sheet が top snap に到達したら、その時点以降は
  `isScrollLockEnabled = false` に切り替えてよい。
  - 結果：middle snap から top snap に到達した後、同じ gesture のまま
    上方向にさらに引くと inner scroll view がスクロールできる。
  - ただし `.onlyAtGestureStart` により、「開始時に scroll view が top edge だったか」
    の判定は変わらない。したがって、以後の下方向ドラッグで outer が再起動するかは
    gesture 開始時の scroll 状態に依存する。

### 3.2 Gesture 開始時に top snap にいたとき

Rideau は gesture 中通して `isScrollLockEnabled = false` を維持する。
実際の挙動は submodule の `.onlyAtGestureStart` が決定する。

#### 3.2.1 開始時 scroll view が top edge にいた場合

- 上方向ドラッグ → submodule が outer を起動しない（`targetEdges = .top`、
  上方向は `.bottom` edge 判定で targetEdges 外）。scroll view は top 固定のまま。
  top 方向への引きは UIScrollView 自身の bounces が担う。
- 下方向ドラッグ → submodule が outer を起動
  （`scrollableEdges.contains(.top) == false && initialScrollableEdges.contains(.top) == false`）。
  sheet が下がる。

#### 3.2.2 開始時 scroll view が top edge **より下**にいた場合

- `initialScrollableEdges.contains(.top) == true`（開始時は上にスクロール可能）なので、
  `.onlyAtGestureStart` は outer を一切起動しない。
- 上方向ドラッグ → scroll view が内部スクロール。
- 下方向ドラッグ → scroll view が内部スクロール。scroll view が top edge に到達しても
  sheet は動かず、UIScrollView の bounces のみ発生。
- この gesture 中に sheet を下げたい場合、ユーザーは一度指を離して再度 gesture を
  始める必要がある。

### 3.3 水平成分・他の縁

- `targetEdges: .top`。bottom edge でのコーディネーションは行わない。
- 水平スクロールは常に自由（ロックしない）。

### 3.4 15pt ゲート

- submodule の `minimumActivationDistance: 15` に一元化。
- Rideau 側では独自のゲートを持たない。`onChange` が来た時点で
  「ユーザーは 15pt 以上動かした」と信じる。

### 3.5 外部ジェスチャー（`register(other:)`）

- sheet 外の `UIPanGestureRecognizer` からの入力は submodule を経由せず、
  直接 `handleDragChange` / `handleDragEnd` に流れる。
- この経路には inner scroll view の関与がないため scroll lock フラグは無関係。
  §3.1 相当で振る舞う。

## 4. Gesture 終了時のスナップ決定

- 終了位置 `nextPosition`：
  - `between(range)`：
    - `|vy| <= |vx|` → 近い方の snap。
    - `|vy| <= 400` → 近い方の snap。
    - `vy < -400` → `range.start`（上側の snap）。
    - `vy > 400` → `range.end`（下側の snap）。
  - `exact` / `outOfStart` / `outOfEnd` → その snap。
- `target == .hidden` になったら以降の入力は拒否（`isTerminated = true`）。
- アニメーション：`UIViewPropertyAnimator` + `UISpringTimingParameters`。
  `resizeToVisibleArea` か否かで damping/response/velocity 計算が異なる。

## 5. アウトオブレンジ挙動（rubber-band）

- 数式は `FluidGroup/swift-rubber-banding` の `rubberBand(value:min:max:bandLength:)` を用いる。
  - `f(x) = L * (1 - 1 / (x * 0.55 / L + 1))` — UIKit 標準と同じ Apple 係数。
  - フレーム刻み依存の `deltaTranslation * 0.1` 線形減衰は廃止し、
    **gesture 開始時からの累積 translation ベース**の絶対計算に切り替える。
- 適用境界：**top snap と bottom-most visible snap の両方**。
  hidden 遷移は rubber-band 対象外（§4 に従う）。
- 見た目の適用先：`containerViewHeightConstraint` を伸縮させる
  （hiding offset は最近接 snap の値にクランプ）。

  疑似コード：

  ```swift
  let nearest = (outOfStart) ? topSnap : bottomSnap
  let overshoot = nextHidingOffset - nearest.hidingOffset   // signed
  let banded = rubberBand(
    value: Double(overshoot),
    min: 0,
    max: 0,
    bandLength: 20
  )
  containerViewBottomConstraint.constant = nearest.hidingOffset
  containerViewHeightConstraint.constant =
    resolvedState.maximumContainerViewHeight - CGFloat(banded)
  containerView.updateLayoutGuideBottomOffset(0)
  ```

- `bandLength = 20` 固定（swiftui-blanket の height rubber-band と同じ）。最大ストレッチ量が 20pt 程度に締まり、境界を超えたことが触覚的に伝わる。
- この rubber-band は **`isScrollLockEnabled == true` または submodule が outer を
  起動中のときのみ**発生する。inner scroll view が gesture を所有している間
  （§3.2.2 全域、§3.2.1 の上方向）は、scroll view 自身の `bounces` が rubber-band を担う。
  Rideau 側で二重に rubber-band を適用しないこと。

## 6. Submodule 要件

- `isScrollLockEnabled` を動的に切り替えられる
- `targetEdges` 指定
- `edgeActivationMode: .onlyAtGestureStart`
- `minimumActivationDistance`
- ロック時／解除時の deceleration キャンセル
- ロック中の scroll indicator 非表示

最低バージョン：`swiftui-scrollview-interoperable-drag-gesture` `0.4.0`。

## 7. 受け入れテスト

`RideauDemo`（SwiftUI / UIKit 両方）で：

- **T1**（§3.1）: middle snap から上ドラッグ → sheet が top snap へ。scroll view は動かない。
- **T2**（§3.1）: middle snap から下ドラッグ → sheet が下の snap / hidden へ。
- **T3**（§3.1 端到達）: middle snap から勢いよく上ドラッグして top snap に到達、
  指を離さず続けて上方向 → inner scroll view がスクロールを引き継ぐ。
- **T4**（§3.2.1）: top snap、scroll view も top edge。上ドラッグ → scroll view の bounces、
  sheet は動かず。
- **T5**（§3.2.1）: top snap、scroll view も top edge。下ドラッグ → sheet が下がる。
- **T6**（§3.2.1 反転）: T5 から指を離さず上方向に反転 → sheet が上がり
  （outer 経由、sticksToEdges 効果で scroll は locked のまま）、top snap に届いた後
  さらに上 → inner scroll view が制御を取り戻す。
- **T7**（§3.2.2）: top snap、scroll view は中ほど。下ドラッグ → scroll view が内部スクロール。
  top edge に達しても sheet は動かず、UIScrollView の bounces のみ。
- **T8**（§3.2.2 短距離）: T7 と同じ状況で、scroll view が top edge に達する前に指を離す
  → sheet は動かない。
- **T9**（§3.4）: 15pt 未満の jiggle では sheet も scroll view も動かない／ロックされない。
- **T10a**（§5）: top snap からさらに上に強く引く → UIScrollView の bounces と同じ感触の
  rubber-band（引くほど抵抗が指数的に増える）、離すとスプリング復帰。
- **T10b**（§5）: bottom-most snap から下に強く引く → 対称に rubber-band。離すと復帰。
- **T10c**（§5 再現性）: 同じ translation で 2 回引いたとき、毎回ほぼ同じ視覚位置になる。
- **T11**（decel fix）: scroll view を強く flick → 慣性中に sheet を掴んで下へ引く
  → 慣性は即キャンセル、sheet が指に追従。
