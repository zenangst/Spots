# Change Log

## [Unreleased](https://github.com/hyperoslo/Spots/tree/HEAD)

[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.4.2...HEAD)

**Merged pull requests:**

- Floor width to only rely on whole numbers [\#791](https://github.com/hyperoslo/Spots/pull/791) ([zenangst](https://github.com/zenangst))
- Optimize/spots scrollview on ios and tvos [\#790](https://github.com/hyperoslo/Spots/pull/790) ([zenangst](https://github.com/zenangst))

## [7.4.2](https://github.com/hyperoslo/Spots/tree/7.4.2) (2018-01-02)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.4.1...7.4.2)

**Merged pull requests:**

- Set focused item index to zero if index is nil when updating the delegates [\#789](https://github.com/hyperoslo/Spots/pull/789) ([zenangst](https://github.com/zenangst))

## [7.4.1](https://github.com/hyperoslo/Spots/tree/7.4.1) (2018-01-01)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.4.0...7.4.1)

**Merged pull requests:**

- Remove unwanted print statement [\#788](https://github.com/hyperoslo/Spots/pull/788) ([zenangst](https://github.com/zenangst))

## [7.4.0](https://github.com/hyperoslo/Spots/tree/7.4.0) (2017-12-29)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.3.0...7.4.0)

**Merged pull requests:**

- Improve/internal performance [\#787](https://github.com/hyperoslo/Spots/pull/787) ([zenangst](https://github.com/zenangst))
- Feature visibleIndexes on UserInterface [\#786](https://github.com/hyperoslo/Spots/pull/786) ([zenangst](https://github.com/zenangst))

## [7.3.0](https://github.com/hyperoslo/Spots/tree/7.3.0) (2017-12-28)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.2.1...7.3.0)

**Merged pull requests:**

- Feature/support for collection view titles [\#785](https://github.com/hyperoslo/Spots/pull/785) ([zenangst](https://github.com/zenangst))
- Refactor sizing implementation to fix accelerated scrolling on tvOS. [\#784](https://github.com/hyperoslo/Spots/pull/784) ([zenangst](https://github.com/zenangst))

## [7.2.1](https://github.com/hyperoslo/Spots/tree/7.2.1) (2017-12-20)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.2.0...7.2.1)

**Merged pull requests:**

- Add needsLayout to setup\(\) & layout\(\) methods on Component [\#783](https://github.com/hyperoslo/Spots/pull/783) ([zenangst](https://github.com/zenangst))

## [7.2.0](https://github.com/hyperoslo/Spots/tree/7.2.0) (2017-12-14)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.1.0...7.2.0)

**Merged pull requests:**

- Feature/built in injection support [\#782](https://github.com/hyperoslo/Spots/pull/782) ([zenangst](https://github.com/zenangst))

## [7.1.0](https://github.com/hyperoslo/Spots/tree/7.1.0) (2017-12-10)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.0.2...7.1.0)

**Merged pull requests:**

- Add a generic initializer for ComponentModel [\#781](https://github.com/hyperoslo/Spots/pull/781) ([zenangst](https://github.com/zenangst))
- Implement support for custom models on ComponentModel's [\#780](https://github.com/hyperoslo/Spots/pull/780) ([zenangst](https://github.com/zenangst))

## [7.0.2](https://github.com/hyperoslo/Spots/tree/7.0.2) (2017-12-06)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.0.1...7.0.2)

**Merged pull requests:**

- Improve focus handling when navigating upwards with multiple horizontal components [\#779](https://github.com/hyperoslo/Spots/pull/779) ([zenangst](https://github.com/zenangst))

## [7.0.1](https://github.com/hyperoslo/Spots/tree/7.0.1) (2017-12-06)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/7.0.0...7.0.1)

**Merged pull requests:**

- Fix bug with setting wrong width when using span [\#778](https://github.com/hyperoslo/Spots/pull/778) ([zenangst](https://github.com/zenangst))

## [7.0.0](https://github.com/hyperoslo/Spots/tree/7.0.0) (2017-12-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/6.1.2...7.0.0)

**Implemented enhancements:**

- Add a test for checking the new `clean` property in `prepareItems`. [\#574](https://github.com/hyperoslo/Spots/issues/574)

**Fixed bugs:**

- Keep selection on tvOS when reloading with components [\#407](https://github.com/hyperoslo/Spots/issues/407)

**Closed issues:**

- Item with uilabel not expanding with text after sizeToFit [\#661](https://github.com/hyperoslo/Spots/issues/661)

**Merged pull requests:**

- Feature focus guide on Component [\#777](https://github.com/hyperoslo/Spots/pull/777) ([zenangst](https://github.com/zenangst))
- Add type to view\(at:\) method on UserInterface [\#776](https://github.com/hyperoslo/Spots/pull/776) ([zenangst](https://github.com/zenangst))
- Use width from presenter if span is set to 0 [\#775](https://github.com/hyperoslo/Spots/pull/775) ([zenangst](https://github.com/zenangst))
- Optimize tvOS performance [\#774](https://github.com/hyperoslo/Spots/pull/774) ([zenangst](https://github.com/zenangst))
- Improve/fast scrolling on tvos part4 [\#773](https://github.com/hyperoslo/Spots/pull/773) ([zenangst](https://github.com/zenangst))
- Improve/fast scrolling on tvos part3 [\#772](https://github.com/hyperoslo/Spots/pull/772) ([zenangst](https://github.com/zenangst))
- Improve `delegate.didReachEnd` algorithm [\#771](https://github.com/hyperoslo/Spots/pull/771) ([zenangst](https://github.com/zenangst))
- Refactor SpotsScrollView to work better with fast scrolling in vertical collection views [\#770](https://github.com/hyperoslo/Spots/pull/770) ([zenangst](https://github.com/zenangst))
- Fix bug when you try to reload an empty Component [\#769](https://github.com/hyperoslo/Spots/pull/769) ([zenangst](https://github.com/zenangst))
- Allow scroll views to scroll inside SpotsScrollView [\#768](https://github.com/hyperoslo/Spots/pull/768) ([zenangst](https://github.com/zenangst))
- Improve the FocusEngineManager when using grids [\#767](https://github.com/hyperoslo/Spots/pull/767) ([zenangst](https://github.com/zenangst))
- Fixes bug where completion is run multiple times [\#766](https://github.com/hyperoslo/Spots/pull/766) ([zenangst](https://github.com/zenangst))
- Improve: item model equatable [\#765](https://github.com/hyperoslo/Spots/pull/765) ([vadymmarkov](https://github.com/vadymmarkov))
- Optimize component layout methods [\#764](https://github.com/hyperoslo/Spots/pull/764) ([zenangst](https://github.com/zenangst))
- Optimize component setup and prepare methods [\#763](https://github.com/hyperoslo/Spots/pull/763) ([zenangst](https://github.com/zenangst))
- Move diffing to interactive thread [\#762](https://github.com/hyperoslo/Spots/pull/762) ([zenangst](https://github.com/zenangst))
- Fix typos, improve grammar in Readme [\#761](https://github.com/hyperoslo/Spots/pull/761) ([richardtop](https://github.com/richardtop))
- Improve comparing models [\#760](https://github.com/hyperoslo/Spots/pull/760) ([zenangst](https://github.com/zenangst))
- Include iOS-Exclusive [\#759](https://github.com/hyperoslo/Spots/pull/759) ([onmyway133](https://github.com/onmyway133))
- Remove RxSpot [\#758](https://github.com/hyperoslo/Spots/pull/758) ([onmyway133](https://github.com/onmyway133))
- Add model configuration to header and footers [\#757](https://github.com/hyperoslo/Spots/pull/757) ([zenangst](https://github.com/zenangst))
- Update Spots.podspec [\#756](https://github.com/hyperoslo/Spots/pull/756) ([zenangst](https://github.com/zenangst))
- Merge branch 'master' into feature/codable [\#755](https://github.com/hyperoslo/Spots/pull/755) ([zenangst](https://github.com/zenangst))
- Feature: Codable support [\#754](https://github.com/hyperoslo/Spots/pull/754) ([vadymmarkov](https://github.com/vadymmarkov))
- Fix focus engine bug when reaching the top. [\#753](https://github.com/hyperoslo/Spots/pull/753) ([zenangst](https://github.com/zenangst))
- Remove manual handling of content offset for horizontal components [\#752](https://github.com/hyperoslo/Spots/pull/752) ([zenangst](https://github.com/zenangst))
- Improve focus engine for tvOS - part something something [\#751](https://github.com/hyperoslo/Spots/pull/751) ([zenangst](https://github.com/zenangst))
-  Replace Mappable with Codable [\#750](https://github.com/hyperoslo/Spots/pull/750) ([vadymmarkov](https://github.com/vadymmarkov))
- Codable refactoring: Implement custom coders [\#749](https://github.com/hyperoslo/Spots/pull/749) ([vadymmarkov](https://github.com/vadymmarkov))
- Feature: Implement Codable [\#748](https://github.com/hyperoslo/Spots/pull/748) ([vadymmarkov](https://github.com/vadymmarkov))
- Swift4 migration [\#747](https://github.com/hyperoslo/Spots/pull/747) ([vadymmarkov](https://github.com/vadymmarkov))
- Merge Swift 4 with master [\#746](https://github.com/hyperoslo/Spots/pull/746) ([zenangst](https://github.com/zenangst))
- Autumn code cleaning [\#745](https://github.com/hyperoslo/Spots/pull/745) ([zenangst](https://github.com/zenangst))
- Migrate source code to Swift 4 [\#744](https://github.com/hyperoslo/Spots/pull/744) ([vadymmarkov](https://github.com/vadymmarkov))
- Refactor Configuration to be injected [\#743](https://github.com/hyperoslo/Spots/pull/743) ([zenangst](https://github.com/zenangst))
- Refactor/hard medium soft updates implementation [\#742](https://github.com/hyperoslo/Spots/pull/742) ([zenangst](https://github.com/zenangst))
- Sanitize naming in tests and add additional to improve coverage [\#741](https://github.com/hyperoslo/Spots/pull/741) ([zenangst](https://github.com/zenangst))
- Feature item models [\#740](https://github.com/hyperoslo/Spots/pull/740) ([zenangst](https://github.com/zenangst))
- Add additional delegate methods for controlling scrolling on tvOS [\#739](https://github.com/hyperoslo/Spots/pull/739) ([zenangst](https://github.com/zenangst))

## [6.1.2](https://github.com/hyperoslo/Spots/tree/6.1.2) (2017-10-04)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/6.1.1...6.1.2)

**Merged pull requests:**

- Release 6.1.2 [\#738](https://github.com/hyperoslo/Spots/pull/738) ([zenangst](https://github.com/zenangst))

## [6.1.1](https://github.com/hyperoslo/Spots/tree/6.1.1) (2017-10-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/6.1.0...6.1.1)

**Closed issues:**

- Enable linting [\#725](https://github.com/hyperoslo/Spots/issues/725)
- Event handling [\#723](https://github.com/hyperoslo/Spots/issues/723)
- Update Example apps [\#644](https://github.com/hyperoslo/Spots/issues/644)

**Merged pull requests:**

- Opt-out from using auto resizing cells [\#737](https://github.com/hyperoslo/Spots/pull/737) ([zenangst](https://github.com/zenangst))
- Opt-out from using auto resizing cells [\#736](https://github.com/hyperoslo/Spots/pull/736) ([zenangst](https://github.com/zenangst))
- Don't call layoutSubviews directly. [\#735](https://github.com/hyperoslo/Spots/pull/735) ([zenangst](https://github.com/zenangst))
- Refactor key-value observing in SpotsScrollView and remove SpotsScrollViewManager's constrain method [\#734](https://github.com/hyperoslo/Spots/pull/734) ([zenangst](https://github.com/zenangst))
- Improve/tvos implementation part deux [\#733](https://github.com/hyperoslo/Spots/pull/733) ([zenangst](https://github.com/zenangst))
- Implement focus guide on SpotsController for tvOS [\#732](https://github.com/hyperoslo/Spots/pull/732) ([zenangst](https://github.com/zenangst))
- Remove everything related to composition [\#731](https://github.com/hyperoslo/Spots/pull/731) ([zenangst](https://github.com/zenangst))
- Improve tvOS implementation [\#730](https://github.com/hyperoslo/Spots/pull/730) ([zenangst](https://github.com/zenangst))
- Implement missing methods for the tvOS focus engine to work with custom views [\#728](https://github.com/hyperoslo/Spots/pull/728) ([zenangst](https://github.com/zenangst))
- Remove outdated Spots examples [\#727](https://github.com/hyperoslo/Spots/pull/727) ([zenangst](https://github.com/zenangst))
- Add Swiftlint script phase [\#726](https://github.com/hyperoslo/Spots/pull/726) ([zenangst](https://github.com/zenangst))
- Wrap update configurable item in `performUpdates` [\#724](https://github.com/hyperoslo/Spots/pull/724) ([zenangst](https://github.com/zenangst))
- Add height constraint to components used inside a controller [\#722](https://github.com/hyperoslo/Spots/pull/722) ([zenangst](https://github.com/zenangst))
- Move collection view extension into shared folder [\#721](https://github.com/hyperoslo/Spots/pull/721) ([zenangst](https://github.com/zenangst))
- Improve rendering on macOS [\#720](https://github.com/hyperoslo/Spots/pull/720) ([zenangst](https://github.com/zenangst))
- Feature collection view extension to get layout as flow layout [\#719](https://github.com/hyperoslo/Spots/pull/719) ([zenangst](https://github.com/zenangst))
- Add additional method on ComponentDelegate to get notification of selection changes [\#718](https://github.com/hyperoslo/Spots/pull/718) ([zenangst](https://github.com/zenangst))
- Refactor macOS layout implementation [\#717](https://github.com/hyperoslo/Spots/pull/717) ([zenangst](https://github.com/zenangst))
- Reload header and footer after update [\#716](https://github.com/hyperoslo/Spots/pull/716) ([vadymmarkov](https://github.com/vadymmarkov))
- Implement functionality to reload component header and footer [\#715](https://github.com/hyperoslo/Spots/pull/715) ([vadymmarkov](https://github.com/vadymmarkov))
- Add max to calculateSpanWidth [\#714](https://github.com/hyperoslo/Spots/pull/714) ([zenangst](https://github.com/zenangst))
- Move sizeForItem to ItemManager and improve safety [\#713](https://github.com/hyperoslo/Spots/pull/713) ([zenangst](https://github.com/zenangst))
- Include .relations when comparing two items [\#712](https://github.com/hyperoslo/Spots/pull/712) ([zenangst](https://github.com/zenangst))
- Improve registering views [\#711](https://github.com/hyperoslo/Spots/pull/711) ([zenangst](https://github.com/zenangst))
- Refactor Component+Core to be less dependent on the user interface [\#710](https://github.com/hyperoslo/Spots/pull/710) ([zenangst](https://github.com/zenangst))
- Add comment to why we compare the superview to components [\#709](https://github.com/hyperoslo/Spots/pull/709) ([zenangst](https://github.com/zenangst))
- Remove rect optimization for horizontal components. [\#708](https://github.com/hyperoslo/Spots/pull/708) ([zenangst](https://github.com/zenangst))
- Only allow other gestures that are attached to views that reside in componentsView [\#707](https://github.com/hyperoslo/Spots/pull/707) ([zenangst](https://github.com/zenangst))
- Set numberOfPages on page control in `afterUpdate` [\#706](https://github.com/hyperoslo/Spots/pull/706) ([zenangst](https://github.com/zenangst))
- Refactor user interface extensions to not wrap cells [\#705](https://github.com/hyperoslo/Spots/pull/705) ([zenangst](https://github.com/zenangst))
- Change refreshControl to be open instead of public [\#704](https://github.com/hyperoslo/Spots/pull/704) ([zenangst](https://github.com/zenangst))
- Improve automatic animation for component flow layout [\#703](https://github.com/hyperoslo/Spots/pull/703) ([zenangst](https://github.com/zenangst))
- Fix crash related to queue jumping [\#702](https://github.com/hyperoslo/Spots/pull/702) ([zenangst](https://github.com/zenangst))
- Move computation to a different thread [\#701](https://github.com/hyperoslo/Spots/pull/701) ([zenangst](https://github.com/zenangst))
- Improve user experience by jumping threads [\#699](https://github.com/hyperoslo/Spots/pull/699) ([zenangst](https://github.com/zenangst))
- Implement DiffManager in Spots [\#698](https://github.com/hyperoslo/Spots/pull/698) ([zenangst](https://github.com/zenangst))
- Adds DiffManager [\#697](https://github.com/hyperoslo/Spots/pull/697) ([zenangst](https://github.com/zenangst))
- Refactor ComponentManager.reloadIfNeeded to use item diffs [\#696](https://github.com/hyperoslo/Spots/pull/696) ([zenangst](https://github.com/zenangst))
- Fix rendering issue related to .integral in SpotsScrollView [\#695](https://github.com/hyperoslo/Spots/pull/695) ([zenangst](https://github.com/zenangst))
- Add ComponentResolvable protocol [\#694](https://github.com/hyperoslo/Spots/pull/694) ([zenangst](https://github.com/zenangst))
- Improve/datasource implementations [\#693](https://github.com/hyperoslo/Spots/pull/693) ([zenangst](https://github.com/zenangst))
- Refactor updating the data source using performUpdate method [\#692](https://github.com/hyperoslo/Spots/pull/692) ([zenangst](https://github.com/zenangst))
- Store contentOffset before switching out components in controller [\#691](https://github.com/hyperoslo/Spots/pull/691) ([zenangst](https://github.com/zenangst))
- Add workaround for contentInsets when using tabs [\#690](https://github.com/hyperoslo/Spots/pull/690) ([zenangst](https://github.com/zenangst))
- Implement proper Interaction.mouseClick behavior for NSCollectionView [\#689](https://github.com/hyperoslo/Spots/pull/689) ([zenangst](https://github.com/zenangst))
- Optimize ComponentFlowLayout [\#688](https://github.com/hyperoslo/Spots/pull/688) ([zenangst](https://github.com/zenangst))
- Refactor ComponentModel to make Layout non-optional [\#686](https://github.com/hyperoslo/Spots/pull/686) ([zenangst](https://github.com/zenangst))
- Refactor/spots scroll view and spots content view [\#685](https://github.com/hyperoslo/Spots/pull/685) ([zenangst](https://github.com/zenangst))
- Improve Component animations [\#684](https://github.com/hyperoslo/Spots/pull/684) ([zenangst](https://github.com/zenangst))
- Implement Component animations [\#683](https://github.com/hyperoslo/Spots/pull/683) ([zenangst](https://github.com/zenangst))
- Implement layoutSubviews\(\) on SpotsContentView [\#682](https://github.com/hyperoslo/Spots/pull/682) ([zenangst](https://github.com/zenangst))
- Reduce code duplication in ItemManager [\#681](https://github.com/hyperoslo/Spots/pull/681) ([zenangst](https://github.com/zenangst))
- Fix scrolling being disabled when starting with an empty collection. [\#680](https://github.com/hyperoslo/Spots/pull/680) ([zenangst](https://github.com/zenangst))
- Fix bug in ComponentManager.insert [\#679](https://github.com/hyperoslo/Spots/pull/679) ([zenangst](https://github.com/zenangst))
- Implement animations for NSCollectionView and ComponentFlowLayout [\#678](https://github.com/hyperoslo/Spots/pull/678) ([zenangst](https://github.com/zenangst))
- Implement showEmptyComponent on Layout [\#677](https://github.com/hyperoslo/Spots/pull/677) ([zenangst](https://github.com/zenangst))
- Implement height adjustments for carousel items [\#676](https://github.com/hyperoslo/Spots/pull/676) ([zenangst](https://github.com/zenangst))
- Apply animation after guard [\#675](https://github.com/hyperoslo/Spots/pull/675) ([zenangst](https://github.com/zenangst))
- Fix bug in ComponentManager.insert [\#674](https://github.com/hyperoslo/Spots/pull/674) ([zenangst](https://github.com/zenangst))
- Fix bug using wrong algorithm in NSCollectionView [\#673](https://github.com/hyperoslo/Spots/pull/673) ([zenangst](https://github.com/zenangst))
- Prepare items before calling layout in carousel extension [\#672](https://github.com/hyperoslo/Spots/pull/672) ([zenangst](https://github.com/zenangst))
- Refactor layoutHorizontalCollectionView on macOS [\#671](https://github.com/hyperoslo/Spots/pull/671) ([zenangst](https://github.com/zenangst))
- Improve performance in reload method by opting-out of cleanup [\#670](https://github.com/hyperoslo/Spots/pull/670) ([zenangst](https://github.com/zenangst))
- Refactor for-loop to use better naming [\#669](https://github.com/hyperoslo/Spots/pull/669) ([zenangst](https://github.com/zenangst))
- Opt-out from doing diffing if the controller is empty [\#668](https://github.com/hyperoslo/Spots/pull/668) ([zenangst](https://github.com/zenangst))
- Implement move animation and move algorithm [\#667](https://github.com/hyperoslo/Spots/pull/667) ([zenangst](https://github.com/zenangst))
- Return .zero height when there are now items [\#666](https://github.com/hyperoslo/Spots/pull/666) ([zenangst](https://github.com/zenangst))
- Pass animation to reloadIfNeeded [\#665](https://github.com/hyperoslo/Spots/pull/665) ([zenangst](https://github.com/zenangst))
- Fixes bug when appending the first item in a collection [\#664](https://github.com/hyperoslo/Spots/pull/664) ([zenangst](https://github.com/zenangst))
- Set masksToBounds to false on UITableView and UICollectionView [\#663](https://github.com/hyperoslo/Spots/pull/663) ([zenangst](https://github.com/zenangst))
- Improve syntax for insert method on UITableView+UserInterface extension [\#662](https://github.com/hyperoslo/Spots/pull/662) ([zenangst](https://github.com/zenangst))
- Use containerSize when calling method [\#660](https://github.com/hyperoslo/Spots/pull/660) ([onmyway133](https://github.com/onmyway133))
- Add containerSize [\#659](https://github.com/hyperoslo/Spots/pull/659) ([onmyway133](https://github.com/onmyway133))

## [6.1.0](https://github.com/hyperoslo/Spots/tree/6.1.0) (2017-06-23)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/6.0.3...6.1.0)

**Closed issues:**

- Cant Play add [\#654](https://github.com/hyperoslo/Spots/issues/654)
- no ad was available Apple TV os [\#653](https://github.com/hyperoslo/Spots/issues/653)
- Building Scheme Spots-tvOS exit error 65 [\#648](https://github.com/hyperoslo/Spots/issues/648)

**Merged pull requests:**

- Change "RxCocoa" version [\#658](https://github.com/hyperoslo/Spots/pull/658) ([vadymmarkov](https://github.com/vadymmarkov))
- Remove making a copy of the attributes before caching them [\#657](https://github.com/hyperoslo/Spots/pull/657) ([zenangst](https://github.com/zenangst))
- Update/cache version [\#656](https://github.com/hyperoslo/Spots/pull/656) ([zenangst](https://github.com/zenangst))
- Implement makeView on Registry [\#655](https://github.com/hyperoslo/Spots/pull/655) ([zenangst](https://github.com/zenangst))

## [6.0.3](https://github.com/hyperoslo/Spots/tree/6.0.3) (2017-06-14)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/6.0.2...6.0.3)

**Merged pull requests:**

- Feature scroll view manager [\#652](https://github.com/hyperoslo/Spots/pull/652) ([zenangst](https://github.com/zenangst))
- Improve pagination with item when using item spacing [\#651](https://github.com/hyperoslo/Spots/pull/651) ([zenangst](https://github.com/zenangst))

## [6.0.2](https://github.com/hyperoslo/Spots/tree/6.0.2) (2017-06-12)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/6.0.1...6.0.2)

**Closed issues:**

- CryptoSwift requirement 0.6.0 does not work with Xcode 9. [\#646](https://github.com/hyperoslo/Spots/issues/646)

**Merged pull requests:**

- Fix threading issues [\#650](https://github.com/hyperoslo/Spots/pull/650) ([zenangst](https://github.com/zenangst))
- Improve scrolling behavior when using multiple horizontal components [\#649](https://github.com/hyperoslo/Spots/pull/649) ([zenangst](https://github.com/zenangst))

## [6.0.1](https://github.com/hyperoslo/Spots/tree/6.0.1) (2017-06-09)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.8.4...6.0.1)

**Merged pull requests:**

- Migrate Cache version [\#647](https://github.com/hyperoslo/Spots/pull/647) ([zenangst](https://github.com/zenangst))

## [5.8.4](https://github.com/hyperoslo/Spots/tree/5.8.4) (2017-06-09)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/6.0.0...5.8.4)

## [6.0.0](https://github.com/hyperoslo/Spots/tree/6.0.0) (2017-05-31)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.8.3...6.0.0)

**Implemented enhancements:**

- Remove support for legacy mapping [\#541](https://github.com/hyperoslo/Spots/issues/541)
- Use Swift 3 DispatchQueue [\#432](https://github.com/hyperoslo/Spots/issues/432)
- Proposal: Unify animated/non-animated scrolling delegate APIs [\#429](https://github.com/hyperoslo/Spots/issues/429)
- Remove items in Component [\#536](https://github.com/hyperoslo/Spots/issues/536)
- Improve header and footer [\#530](https://github.com/hyperoslo/Spots/issues/530)
- Use constant values for sizes [\#479](https://github.com/hyperoslo/Spots/issues/479)
- Clarify SpotConfigurable [\#472](https://github.com/hyperoslo/Spots/issues/472)
- Improve `ScrollDelegate` [\#398](https://github.com/hyperoslo/Spots/issues/398)
- Improve `endDisplay\(view: SpotView, item: Item, in spot: Spotable\)` [\#397](https://github.com/hyperoslo/Spots/issues/397)
- Improve `willDisplay\(view: SpotView, item: Item, in spot: Spotable\)` [\#396](https://github.com/hyperoslo/Spots/issues/396)
- Improve `didChange\(spots: \[Spotable\]\)` [\#395](https://github.com/hyperoslo/Spots/issues/395)
- Refactor `render\(\)` into `view`. [\#392](https://github.com/hyperoslo/Spots/issues/392)
- Improve didSelect method [\#391](https://github.com/hyperoslo/Spots/issues/391)
- Improve the documentation [\#290](https://github.com/hyperoslo/Spots/issues/290)

**Fixed bugs:**

- Add register nib on Configuration [\#542](https://github.com/hyperoslo/Spots/issues/542)
- Update README to reflect 6.0.0 [\#539](https://github.com/hyperoslo/Spots/issues/539)
- Configure closure does't work with list wrapper \(6.0\) [\#463](https://github.com/hyperoslo/Spots/issues/463)

**Closed issues:**

- Method does not override any method from its superclass [\#582](https://github.com/hyperoslo/Spots/issues/582)
- All in one App ? [\#415](https://github.com/hyperoslo/Spots/issues/415)

**Merged pull requests:**

- Fix compiler error on tvOS [\#645](https://github.com/hyperoslo/Spots/pull/645) ([zenangst](https://github.com/zenangst))
- Scope SpotsRefreshControl to only be available on iOS [\#643](https://github.com/hyperoslo/Spots/pull/643) ([zenangst](https://github.com/zenangst))
- Add link to changelog in README.md [\#642](https://github.com/hyperoslo/Spots/pull/642) ([zenangst](https://github.com/zenangst))
- Fix/broken links [\#641](https://github.com/hyperoslo/Spots/pull/641) ([zenangst](https://github.com/zenangst))
- Split README into multiple md files [\#640](https://github.com/hyperoslo/Spots/pull/640) ([zenangst](https://github.com/zenangst))
- Add migration md file [\#639](https://github.com/hyperoslo/Spots/pull/639) ([zenangst](https://github.com/zenangst))
- Rename file to reflect the type and remove case .row [\#638](https://github.com/hyperoslo/Spots/pull/638) ([zenangst](https://github.com/zenangst))
- Fix header view scrolling with content. [\#637](https://github.com/hyperoslo/Spots/pull/637) ([zenangst](https://github.com/zenangst))
- Improve ComponentFlowLayout use of layout attributes [\#636](https://github.com/hyperoslo/Spots/pull/636) ([zenangst](https://github.com/zenangst))
- Update Getting started guide.md [\#635](https://github.com/hyperoslo/Spots/pull/635) ([zenangst](https://github.com/zenangst))
- Feature getting started guide [\#634](https://github.com/hyperoslo/Spots/pull/634) ([zenangst](https://github.com/zenangst))
- Refactor size calculations for carousel views. [\#633](https://github.com/hyperoslo/Spots/pull/633) ([zenangst](https://github.com/zenangst))
- Add init\(padding:\) on Inset [\#632](https://github.com/hyperoslo/Spots/pull/632) ([zenangst](https://github.com/zenangst))
- Remove the use of \<- operator in carousel extension [\#631](https://github.com/hyperoslo/Spots/pull/631) ([zenangst](https://github.com/zenangst))
- Add documentation for Delegate class [\#630](https://github.com/hyperoslo/Spots/pull/630) ([zenangst](https://github.com/zenangst))
- Improve Layout implementation and tests [\#629](https://github.com/hyperoslo/Spots/pull/629) ([zenangst](https://github.com/zenangst))
- Rename all references of GridableLayout to ComponentFlowLayout [\#628](https://github.com/hyperoslo/Spots/pull/628) ([zenangst](https://github.com/zenangst))
- Implement stretch last component feature on macOS [\#627](https://github.com/hyperoslo/Spots/pull/627) ([zenangst](https://github.com/zenangst))
- Improve GridableLayout by including line spacing [\#626](https://github.com/hyperoslo/Spots/pull/626) ([zenangst](https://github.com/zenangst))
- Improve updateIfNeeded to perform more accurate updates [\#625](https://github.com/hyperoslo/Spots/pull/625) ([zenangst](https://github.com/zenangst))
- Improve updateIfNeeded on SpotsControllerManager [\#624](https://github.com/hyperoslo/Spots/pull/624) ([zenangst](https://github.com/zenangst))
- Remove stretchSingleComponent feature [\#623](https://github.com/hyperoslo/Spots/pull/623) ([zenangst](https://github.com/zenangst))
- Invoke layoutViews on SpotsScrollView [\#622](https://github.com/hyperoslo/Spots/pull/622) ([zenangst](https://github.com/zenangst))
- Don't rely on item.index, use target index instead [\#621](https://github.com/hyperoslo/Spots/pull/621) ([zenangst](https://github.com/zenangst))
- Add support for Component stretching. [\#620](https://github.com/hyperoslo/Spots/pull/620) ([zenangst](https://github.com/zenangst))
- Make computeSize open so that you can override it. [\#619](https://github.com/hyperoslo/Spots/pull/619) ([zenangst](https://github.com/zenangst))
- Feature infinite scrolling for horizontal components on iOS/tvOS [\#618](https://github.com/hyperoslo/Spots/pull/618) ([zenangst](https://github.com/zenangst))
- Feature items per row [\#616](https://github.com/hyperoslo/Spots/pull/616) ([zenangst](https://github.com/zenangst))
- Add documentation header for SpotsControllerManager [\#615](https://github.com/hyperoslo/Spots/pull/615) ([zenangst](https://github.com/zenangst))
- Add documentation header and method documentation to DataSource. [\#614](https://github.com/hyperoslo/Spots/pull/614) ([zenangst](https://github.com/zenangst))
- Add comment header and function documentation for ViewPreparer class. [\#613](https://github.com/hyperoslo/Spots/pull/613) ([zenangst](https://github.com/zenangst))
- Add comment header for ComponentManager [\#612](https://github.com/hyperoslo/Spots/pull/612) ([zenangst](https://github.com/zenangst))
- ⚠️ Refactor ItemConfigurable configure and add compute size ⚠️ [\#611](https://github.com/hyperoslo/Spots/pull/611) ([zenangst](https://github.com/zenangst))
- Move item preparation methods into a new ItemManager class [\#610](https://github.com/hyperoslo/Spots/pull/610) ([zenangst](https://github.com/zenangst))
- ⚠️ Refactor configure closure on Component to use self instead of just the view. [\#609](https://github.com/hyperoslo/Spots/pull/609) ([zenangst](https://github.com/zenangst))
- Update and use new features on Tailor [\#608](https://github.com/hyperoslo/Spots/pull/608) ([zenangst](https://github.com/zenangst))
- Fix collection view layout warnings on macOS [\#607](https://github.com/hyperoslo/Spots/pull/607) ([zenangst](https://github.com/zenangst))
- Improve layout implementation for collection views with header on macOS [\#606](https://github.com/hyperoslo/Spots/pull/606) ([zenangst](https://github.com/zenangst))
- Implement hover behavior on list and grid wrapper on macOS [\#605](https://github.com/hyperoslo/Spots/pull/605) ([zenangst](https://github.com/zenangst))
- Improve delegate trigger when scrolling on macOS [\#604](https://github.com/hyperoslo/Spots/pull/604) ([zenangst](https://github.com/zenangst))
- Fix recursion when using composition and improve composite lookup [\#603](https://github.com/hyperoslo/Spots/pull/603) ([zenangst](https://github.com/zenangst))
- Sync contentSize between collection view and collection view layout [\#602](https://github.com/hyperoslo/Spots/pull/602) ([zenangst](https://github.com/zenangst))
- Remove setting layer to Component.collectionView [\#601](https://github.com/hyperoslo/Spots/pull/601) ([zenangst](https://github.com/zenangst))
- Call layoutSubviews in SpotsControllerManager.update [\#600](https://github.com/hyperoslo/Spots/pull/600) ([zenangst](https://github.com/zenangst))
- Set selection style to .none in ListWrapper on iOS [\#599](https://github.com/hyperoslo/Spots/pull/599) ([zenangst](https://github.com/zenangst))
- Improve overall performance and collection view layout method [\#597](https://github.com/hyperoslo/Spots/pull/597) ([zenangst](https://github.com/zenangst))
- Remove unused files [\#596](https://github.com/hyperoslo/Spots/pull/596) ([zenangst](https://github.com/zenangst))
- macOS implementation improvements [\#595](https://github.com/hyperoslo/Spots/pull/595) ([zenangst](https://github.com/zenangst))
- Feature universal sticky headers [\#594](https://github.com/hyperoslo/Spots/pull/594) ([zenangst](https://github.com/zenangst))
- Refactor composition implementation and improve datasource and delegate [\#593](https://github.com/hyperoslo/Spots/pull/593) ([zenangst](https://github.com/zenangst))
- Fix page indicator position [\#592](https://github.com/hyperoslo/Spots/pull/592) ([zenangst](https://github.com/zenangst))
- Improve iOS implementation when using reload with components [\#591](https://github.com/hyperoslo/Spots/pull/591) ([zenangst](https://github.com/zenangst))
- Refactor SpotsControllerManager [\#590](https://github.com/hyperoslo/Spots/pull/590) ([zenangst](https://github.com/zenangst))
- Refactor ComponentManager [\#589](https://github.com/hyperoslo/Spots/pull/589) ([zenangst](https://github.com/zenangst))
- Call configure method on the view when it will be displayed in the component delegate [\#588](https://github.com/hyperoslo/Spots/pull/588) ([zenangst](https://github.com/zenangst))
- Clean up implementation [\#587](https://github.com/hyperoslo/Spots/pull/587) ([zenangst](https://github.com/zenangst))
- Improve documentation for SpotsControllerManager [\#586](https://github.com/hyperoslo/Spots/pull/586) ([zenangst](https://github.com/zenangst))
- Rename file and make extension live on SpotsController [\#585](https://github.com/hyperoslo/Spots/pull/585) ([zenangst](https://github.com/zenangst))
- Feature SpotsControllerManager [\#584](https://github.com/hyperoslo/Spots/pull/584) ([zenangst](https://github.com/zenangst))
- Implement ComponentManager [\#583](https://github.com/hyperoslo/Spots/pull/583) ([zenangst](https://github.com/zenangst))
- Feature scrollTo and itemOffset methods for doing interactive UI [\#581](https://github.com/hyperoslo/Spots/pull/581) ([zenangst](https://github.com/zenangst))
- Return wrapped view instead of wrapper view [\#580](https://github.com/hyperoslo/Spots/pull/580) ([zenangst](https://github.com/zenangst))
- Feature reload with component models [\#579](https://github.com/hyperoslo/Spots/pull/579) ([zenangst](https://github.com/zenangst))
- Move page indicator related code to layout instead of setup [\#578](https://github.com/hyperoslo/Spots/pull/578) ([zenangst](https://github.com/zenangst))
- Improve collection views on iOS [\#577](https://github.com/hyperoslo/Spots/pull/577) ([zenangst](https://github.com/zenangst))
- Set background to clear instead of white in GridWrapper on iOS/tvOS [\#576](https://github.com/hyperoslo/Spots/pull/576) ([zenangst](https://github.com/zenangst))
- Improve Component implementation [\#575](https://github.com/hyperoslo/Spots/pull/575) ([zenangst](https://github.com/zenangst))
- Rename CollectionAdapter+tvOS to Component+tvOS [\#573](https://github.com/hyperoslo/Spots/pull/573) ([zenangst](https://github.com/zenangst))
- Improve reloading composite components, plus performance improvements when resizing windows on macOS [\#572](https://github.com/hyperoslo/Spots/pull/572) ([zenangst](https://github.com/zenangst))
- Remove hybrid label from ComponentModel init [\#571](https://github.com/hyperoslo/Spots/pull/571) ([zenangst](https://github.com/zenangst))
- Keep scroll position after reload with JSON [\#570](https://github.com/hyperoslo/Spots/pull/570) ([zenangst](https://github.com/zenangst))
- Improve handling mouse clicks on macOS [\#567](https://github.com/hyperoslo/Spots/pull/567) ([zenangst](https://github.com/zenangst))
- Remove unused GridableMeta struct [\#566](https://github.com/hyperoslo/Spots/pull/566) ([zenangst](https://github.com/zenangst))
- Spots 6.0.0 [\#565](https://github.com/hyperoslo/Spots/pull/565) ([zenangst](https://github.com/zenangst))
- Clean up use of `Component` aliases [\#564](https://github.com/hyperoslo/Spots/pull/564) ([zenangst](https://github.com/zenangst))
- Remove boilerplate views [\#563](https://github.com/hyperoslo/Spots/pull/563) ([zenangst](https://github.com/zenangst))
- Remove guard else returns as one liners. [\#562](https://github.com/hyperoslo/Spots/pull/562) ([zenangst](https://github.com/zenangst))
- Remove Component.index and .usesDynamicHeight [\#561](https://github.com/hyperoslo/Spots/pull/561) ([zenangst](https://github.com/zenangst))
- Remove span on ComponentModel [\#560](https://github.com/hyperoslo/Spots/pull/560) ([zenangst](https://github.com/zenangst))
- Feature docs for Component on macOS and iOS. [\#559](https://github.com/hyperoslo/Spots/pull/559) ([zenangst](https://github.com/zenangst))
- Remove static header property from Component [\#558](https://github.com/hyperoslo/Spots/pull/558) ([zenangst](https://github.com/zenangst))
- Remove legacy implementations for register and registerAndPrepare [\#557](https://github.com/hyperoslo/Spots/pull/557) ([zenangst](https://github.com/zenangst))
- Improve component model file [\#556](https://github.com/hyperoslo/Spots/pull/556) ([zenangst](https://github.com/zenangst))
- Improve docs in component model [\#555](https://github.com/hyperoslo/Spots/pull/555) ([zenangst](https://github.com/zenangst))
- Remove isHybrid property on ComponentModel [\#554](https://github.com/hyperoslo/Spots/pull/554) ([zenangst](https://github.com/zenangst))
- Remove title property from ComponentModel [\#553](https://github.com/hyperoslo/Spots/pull/553) ([zenangst](https://github.com/zenangst))
- Refactor Component.kind into an enum called ComponentKind [\#552](https://github.com/hyperoslo/Spots/pull/552) ([zenangst](https://github.com/zenangst))
- Remove .views on Component [\#551](https://github.com/hyperoslo/Spots/pull/551) ([zenangst](https://github.com/zenangst))
- Refactor header and footer related code in GridableLayout.prepare\(\) [\#550](https://github.com/hyperoslo/Spots/pull/550) ([zenangst](https://github.com/zenangst))
- Refactor setup and layout signature with `with` label [\#549](https://github.com/hyperoslo/Spots/pull/549) ([zenangst](https://github.com/zenangst))
- Rename Controller to SpotsController [\#547](https://github.com/hyperoslo/Spots/pull/547) ([zenangst](https://github.com/zenangst))
- Fix compiler error in live editing extension [\#546](https://github.com/hyperoslo/Spots/pull/546) ([zenangst](https://github.com/zenangst))
- Fix component configure closure on macOS. [\#545](https://github.com/hyperoslo/Spots/pull/545) ([zenangst](https://github.com/zenangst))
- Remove support for legacy mapping on `ComponentModel` and related models. [\#544](https://github.com/hyperoslo/Spots/pull/544) ([zenangst](https://github.com/zenangst))
- Update README for version 6.0.0 [\#543](https://github.com/hyperoslo/Spots/pull/543) ([zenangst](https://github.com/zenangst))
- Remove items from component [\#538](https://github.com/hyperoslo/Spots/pull/538) ([zenangst](https://github.com/zenangst))
- Replace RowComponent with Component [\#537](https://github.com/hyperoslo/Spots/pull/537) ([zenangst](https://github.com/zenangst))
- Remove all references to ViewComponent aka ViewSpot [\#535](https://github.com/hyperoslo/Spots/pull/535) ([zenangst](https://github.com/zenangst))
- Remove core types and move functionality into extensions on Component [\#534](https://github.com/hyperoslo/Spots/pull/534) ([zenangst](https://github.com/zenangst))
- Improve header and footer height calculations in delegate [\#533](https://github.com/hyperoslo/Spots/pull/533) ([zenangst](https://github.com/zenangst))
- Improve header footer support [\#532](https://github.com/hyperoslo/Spots/pull/532) ([zenangst](https://github.com/zenangst))
- Fix up plists for Rx target [\#531](https://github.com/hyperoslo/Spots/pull/531) ([zenangst](https://github.com/zenangst))
- Improve Component layout on macOS [\#529](https://github.com/hyperoslo/Spots/pull/529) ([zenangst](https://github.com/zenangst))
- Rename contentView to componentsView in `SpotsScrollView` [\#528](https://github.com/hyperoslo/Spots/pull/528) ([zenangst](https://github.com/zenangst))
- Improve Component layout on macOS [\#527](https://github.com/hyperoslo/Spots/pull/527) ([zenangst](https://github.com/zenangst))
- Feature view state support for macOS [\#526](https://github.com/hyperoslo/Spots/pull/526) ([zenangst](https://github.com/zenangst))
- Fix compiler errors with optional assignments. [\#525](https://github.com/hyperoslo/Spots/pull/525) ([zenangst](https://github.com/zenangst))
- Fix faulty method implementation [\#524](https://github.com/hyperoslo/Spots/pull/524) ([zenangst](https://github.com/zenangst))
- Replace weakSelf with strongSelf [\#523](https://github.com/hyperoslo/Spots/pull/523) ([zenangst](https://github.com/zenangst))
- ⚠️ Improve naming by search and replacing more references to spot and spots⚠️ [\#522](https://github.com/hyperoslo/Spots/pull/522) ([zenangst](https://github.com/zenangst))
- \[skip ci\]Merge `master` into `6.0.0` [\#521](https://github.com/hyperoslo/Spots/pull/521) ([zenangst](https://github.com/zenangst))
- ⚠️Rename references of spot\(s\) with component\(s\)⚠️ [\#520](https://github.com/hyperoslo/Spots/pull/520) ([zenangst](https://github.com/zenangst))
- ⚠️Rename core types to use Component instead of Spot suffixes⚠️ [\#519](https://github.com/hyperoslo/Spots/pull/519) ([zenangst](https://github.com/zenangst))
- ⚠️Rename .component to .model⚠️ [\#518](https://github.com/hyperoslo/Spots/pull/518) ([zenangst](https://github.com/zenangst))
- ⚠️ Rename Component to ComponentModel ⚠️ [\#515](https://github.com/hyperoslo/Spots/pull/515) ([zenangst](https://github.com/zenangst))
- Refactor Spot implementation into extensions  [\#514](https://github.com/hyperoslo/Spots/pull/514) ([zenangst](https://github.com/zenangst))
- Feature Grid and Carousel support on Spot for macOS [\#513](https://github.com/hyperoslo/Spots/pull/513) ([zenangst](https://github.com/zenangst))
- Feature list spot implementation for macOS [\#512](https://github.com/hyperoslo/Spots/pull/512) ([zenangst](https://github.com/zenangst))
- Merge commit [\#510](https://github.com/hyperoslo/Spots/pull/510) ([zenangst](https://github.com/zenangst))
- Refactor prepare item methods to make it a tinsy bit smarter [\#508](https://github.com/hyperoslo/Spots/pull/508) ([zenangst](https://github.com/zenangst))
- Optimize prepare\(items:\) method [\#506](https://github.com/hyperoslo/Spots/pull/506) ([zenangst](https://github.com/zenangst))
- Run bundle update [\#505](https://github.com/hyperoslo/Spots/pull/505) ([zenangst](https://github.com/zenangst))
- Merge branch 'master' into feature/danger [\#504](https://github.com/hyperoslo/Spots/pull/504) ([zenangst](https://github.com/zenangst))
- Merge branch 'master' into 6.0.0 [\#503](https://github.com/hyperoslo/Spots/pull/503) ([zenangst](https://github.com/zenangst))
- Refactor Spot init methods [\#502](https://github.com/hyperoslo/Spots/pull/502) ([zenangst](https://github.com/zenangst))
- Fix rxSpots target [\#501](https://github.com/hyperoslo/Spots/pull/501) ([zenangst](https://github.com/zenangst))
- ListSpotCell: Add accessibility support [\#500](https://github.com/hyperoslo/Spots/pull/500) ([JohnSundell](https://github.com/JohnSundell))
- Fix warning [\#499](https://github.com/hyperoslo/Spots/pull/499) ([colorbox](https://github.com/colorbox))
- Improve scrolling behavior for carousel [\#498](https://github.com/hyperoslo/Spots/pull/498) ([zenangst](https://github.com/zenangst))
- Merge branch 'master' into 6.0.0 [\#497](https://github.com/hyperoslo/Spots/pull/497) ([zenangst](https://github.com/zenangst))
- Update README.md [\#496](https://github.com/hyperoslo/Spots/pull/496) ([orta](https://github.com/orta))
- Fix missing configure method [\#495](https://github.com/hyperoslo/Spots/pull/495) ([zenangst](https://github.com/zenangst))
- Fix selected background view for list wrapper [\#494](https://github.com/hyperoslo/Spots/pull/494) ([zenangst](https://github.com/zenangst))
- Feature: view state [\#492](https://github.com/hyperoslo/Spots/pull/492) ([vadymmarkov](https://github.com/vadymmarkov))
- Set backgroundColor to .clear for wrapper views [\#491](https://github.com/hyperoslo/Spots/pull/491) ([zenangst](https://github.com/zenangst))
- Fix carousel scroll indicator [\#490](https://github.com/hyperoslo/Spots/pull/490) ([zenangst](https://github.com/zenangst))
- Refactor DataSource on iOS to reduce code duplication [\#489](https://github.com/hyperoslo/Spots/pull/489) ([zenangst](https://github.com/zenangst))
- Add register default view on Configuration [\#488](https://github.com/hyperoslo/Spots/pull/488) ([zenangst](https://github.com/zenangst))
- Refactor didSet methods on Controller [\#487](https://github.com/hyperoslo/Spots/pull/487) ([zenangst](https://github.com/zenangst))
- Refactor wrapped views setup [\#486](https://github.com/hyperoslo/Spots/pull/486) ([zenangst](https://github.com/zenangst))
- Rename exception to expectation and use type inference [\#485](https://github.com/hyperoslo/Spots/pull/485) ([zenangst](https://github.com/zenangst))
- Fix bug with insets when using paginated scrolling in carousel spots. [\#484](https://github.com/hyperoslo/Spots/pull/484) ([zenangst](https://github.com/zenangst))
- Implement cache for Spot and reduce code duplication in Spot [\#483](https://github.com/hyperoslo/Spots/pull/483) ([zenangst](https://github.com/zenangst))
- Improve/horizontally scrolling views [\#482](https://github.com/hyperoslo/Spots/pull/482) ([zenangst](https://github.com/zenangst))
- Implement hybrid carousel spot [\#481](https://github.com/hyperoslo/Spots/pull/481) ([zenangst](https://github.com/zenangst))
- Refactor implement Item into Spots and replace SpotConfigurable [\#480](https://github.com/hyperoslo/Spots/pull/480) ([zenangst](https://github.com/zenangst))
- Implement hybrid grid spot [\#478](https://github.com/hyperoslo/Spots/pull/478) ([zenangst](https://github.com/zenangst))
- Implement hybrid list spot [\#477](https://github.com/hyperoslo/Spots/pull/477) ([zenangst](https://github.com/zenangst))
- Import Cocoa for OSX [\#476](https://github.com/hyperoslo/Spots/pull/476) ([zenangst](https://github.com/zenangst))
- Reduce code duplication by introducing configureClosureDidChange\(\) [\#475](https://github.com/hyperoslo/Spots/pull/475) ([zenangst](https://github.com/zenangst))
- Add hybrid property on Component [\#474](https://github.com/hyperoslo/Spots/pull/474) ([zenangst](https://github.com/zenangst))
- Switch to Circle CI [\#471](https://github.com/hyperoslo/Spots/pull/471) ([zenangst](https://github.com/zenangst))
- Remove Gridable as a dependency in GridableLayout [\#470](https://github.com/hyperoslo/Spots/pull/470) ([zenangst](https://github.com/zenangst))
- Register default and composite spot in init [\#469](https://github.com/hyperoslo/Spots/pull/469) ([zenangst](https://github.com/zenangst))
- Add skeleton for Spot class [\#468](https://github.com/hyperoslo/Spots/pull/468) ([zenangst](https://github.com/zenangst))
- Fix spot configure closures on iOS [\#467](https://github.com/hyperoslo/Spots/pull/467) ([zenangst](https://github.com/zenangst))
- Move reloadIfNeeded and process to Spotable [\#466](https://github.com/hyperoslo/Spots/pull/466) ([zenangst](https://github.com/zenangst))
- Use section inset to apply component insets [\#464](https://github.com/hyperoslo/Spots/pull/464) ([JohnSundell](https://github.com/JohnSundell))
- Add Dangerfile [\#462](https://github.com/hyperoslo/Spots/pull/462) ([onmyway133](https://github.com/onmyway133))
- Properly resolve wrapped views [\#461](https://github.com/hyperoslo/Spots/pull/461) ([zenangst](https://github.com/zenangst))
- CarouselSpot: Support placing a page indicator as an overlay [\#460](https://github.com/hyperoslo/Spots/pull/460) ([JohnSundell](https://github.com/JohnSundell))
- Fix/vertical scrolling in carousel [\#459](https://github.com/hyperoslo/Spots/pull/459) ([zenangst](https://github.com/zenangst))
- Revert back to precious implementation of setFallbackViewSize [\#458](https://github.com/hyperoslo/Spots/pull/458) ([zenangst](https://github.com/zenangst))
- Fix/failing tests on macos [\#457](https://github.com/hyperoslo/Spots/pull/457) ([zenangst](https://github.com/zenangst))
- CarouselSpot: Fix failing test [\#456](https://github.com/hyperoslo/Spots/pull/456) ([JohnSundell](https://github.com/JohnSundell))
- Remove missing CarouselSpot+iOS extension [\#455](https://github.com/hyperoslo/Spots/pull/455) ([JohnSundell](https://github.com/JohnSundell))
- Registry: Import CoreGraphics \[6.0.0\] [\#454](https://github.com/hyperoslo/Spots/pull/454) ([JohnSundell](https://github.com/JohnSundell))
- Registry: Import CoreGraphics \[master\] [\#453](https://github.com/hyperoslo/Spots/pull/453) ([JohnSundell](https://github.com/JohnSundell))
- Improve GridableLayout contentSize and insets [\#452](https://github.com/hyperoslo/Spots/pull/452) ([zenangst](https://github.com/zenangst))
- RxSpots: SpotsDelegate reactive extensions [\#451](https://github.com/hyperoslo/Spots/pull/451) ([vadymmarkov](https://github.com/vadymmarkov))
- CarouselSpot: Add snapping scroll behavior [\#449](https://github.com/hyperoslo/Spots/pull/449) ([JohnSundell](https://github.com/JohnSundell))
- Improve/init for views [\#448](https://github.com/hyperoslo/Spots/pull/448) ([zenangst](https://github.com/zenangst))
- Use identifier to find kind instead of if statement [\#447](https://github.com/hyperoslo/Spots/pull/447) ([zenangst](https://github.com/zenangst))
- Improve/gridable layout [\#446](https://github.com/hyperoslo/Spots/pull/446) ([zenangst](https://github.com/zenangst))
- Resolve views from Configuration.views [\#445](https://github.com/hyperoslo/Spots/pull/445) ([zenangst](https://github.com/zenangst))
- Set inset only once [\#444](https://github.com/hyperoslo/Spots/pull/444) ([vadymmarkov](https://github.com/vadymmarkov))
- Feature/universal header footers 6.0 [\#443](https://github.com/hyperoslo/Spots/pull/443) ([zenangst](https://github.com/zenangst))
- Feature/universal header footers [\#442](https://github.com/hyperoslo/Spots/pull/442) ([zenangst](https://github.com/zenangst))
- Merge with 'master' [\#441](https://github.com/hyperoslo/Spots/pull/441) ([zenangst](https://github.com/zenangst))
- Feature/core wrappers [\#440](https://github.com/hyperoslo/Spots/pull/440) ([zenangst](https://github.com/zenangst))
- Refactor/cleanup redudant code [\#436](https://github.com/hyperoslo/Spots/pull/436) ([zenangst](https://github.com/zenangst))
- Call layoutSubviews in updateIfNeeded [\#435](https://github.com/hyperoslo/Spots/pull/435) ([zenangst](https://github.com/zenangst))
- Refactor/change mac to macos [\#434](https://github.com/hyperoslo/Spots/pull/434) ([zenangst](https://github.com/zenangst))
- Refactor dispatch [\#433](https://github.com/hyperoslo/Spots/pull/433) ([zenangst](https://github.com/zenangst))
- Improve/project setup [\#431](https://github.com/hyperoslo/Spots/pull/431) ([zenangst](https://github.com/zenangst))
- Feature interaction abstraction [\#430](https://github.com/hyperoslo/Spots/pull/430) ([zenangst](https://github.com/zenangst))
- Refactor delegate methods [\#428](https://github.com/hyperoslo/Spots/pull/428) ([zenangst](https://github.com/zenangst))
- Improve/spotable by renaming render [\#427](https://github.com/hyperoslo/Spots/pull/427) ([zenangst](https://github.com/zenangst))
- Lower case enum cases [\#426](https://github.com/hyperoslo/Spots/pull/426) ([zenangst](https://github.com/zenangst))
- Remove section and content insets, replace it with inset [\#425](https://github.com/hyperoslo/Spots/pull/425) ([zenangst](https://github.com/zenangst))
- Fix content insets [\#424](https://github.com/hyperoslo/Spots/pull/424) ([vadymmarkov](https://github.com/vadymmarkov))
- Fix missing headers in `GridableLayout` [\#423](https://github.com/hyperoslo/Spots/pull/423) ([zenangst](https://github.com/zenangst))
- Apply insects with itemAttribute instead of attribute.frame [\#422](https://github.com/hyperoslo/Spots/pull/422) ([zenangst](https://github.com/zenangst))
- Improve/gridable layout [\#421](https://github.com/hyperoslo/Spots/pull/421) ([zenangst](https://github.com/zenangst))

## [5.8.3](https://github.com/hyperoslo/Spots/tree/5.8.3) (2017-01-19)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.8.2...5.8.3)

**Merged pull requests:**

- Add prepare method for missing layouts on Component [\#420](https://github.com/hyperoslo/Spots/pull/420) ([zenangst](https://github.com/zenangst))

## [5.8.2](https://github.com/hyperoslo/Spots/tree/5.8.2) (2017-01-19)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.8.1...5.8.2)

**Merged pull requests:**

- Set default component layout in Spotable object on macOS [\#419](https://github.com/hyperoslo/Spots/pull/419) ([zenangst](https://github.com/zenangst))
- Fix field offset [\#418](https://github.com/hyperoslo/Spots/pull/418) ([onmyway133](https://github.com/onmyway133))
- Improve Layout struct [\#417](https://github.com/hyperoslo/Spots/pull/417) ([zenangst](https://github.com/zenangst))

## [5.8.1](https://github.com/hyperoslo/Spots/tree/5.8.1) (2017-01-19)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.8.0...5.8.1)

## [5.8.0](https://github.com/hyperoslo/Spots/tree/5.8.0) (2017-01-19)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.7.3...5.8.0)

**Merged pull requests:**

- Feature layout [\#416](https://github.com/hyperoslo/Spots/pull/416) ([zenangst](https://github.com/zenangst))

## [5.7.3](https://github.com/hyperoslo/Spots/tree/5.7.3) (2017-01-17)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.7.2...5.7.3)

**Merged pull requests:**

- Improve/refresh control [\#414](https://github.com/hyperoslo/Spots/pull/414) ([zenangst](https://github.com/zenangst))
- refactor: Fix typos in UITableView+UserInterface [\#413](https://github.com/hyperoslo/Spots/pull/413) ([aashishdhawan](https://github.com/aashishdhawan))
- Bug/fix crash [\#412](https://github.com/hyperoslo/Spots/pull/412) ([aashishdhawan](https://github.com/aashishdhawan))
- Change type precedence [\#411](https://github.com/hyperoslo/Spots/pull/411) ([zenangst](https://github.com/zenangst))

## [5.7.2](https://github.com/hyperoslo/Spots/tree/5.7.2) (2017-01-11)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.7.1...5.7.2)

**Merged pull requests:**

- Improve/reload with components [\#410](https://github.com/hyperoslo/Spots/pull/410) ([zenangst](https://github.com/zenangst))
- Initial implementation of improved focus for tvOS [\#408](https://github.com/hyperoslo/Spots/pull/408) ([zenangst](https://github.com/zenangst))
- Fix broken macOS target [\#406](https://github.com/hyperoslo/Spots/pull/406) ([zenangst](https://github.com/zenangst))
- Fix/layout issue with carousel [\#405](https://github.com/hyperoslo/Spots/pull/405) ([zenangst](https://github.com/zenangst))
- Improve layouting after reload [\#404](https://github.com/hyperoslo/Spots/pull/404) ([zenangst](https://github.com/zenangst))
- Improve/reload with components [\#403](https://github.com/hyperoslo/Spots/pull/403) ([zenangst](https://github.com/zenangst))

## [5.7.1](https://github.com/hyperoslo/Spots/tree/5.7.1) (2017-01-02)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.7.0...5.7.1)

**Implemented enhancements:**

- Improve composition [\#390](https://github.com/hyperoslo/Spots/issues/390)

**Merged pull requests:**

- Call layoutIfNeeded instead of scrollView.layoutSubviews\(\) [\#402](https://github.com/hyperoslo/Spots/pull/402) ([zenangst](https://github.com/zenangst))
- Improve prepare view methods [\#401](https://github.com/hyperoslo/Spots/pull/401) ([zenangst](https://github.com/zenangst))

## [5.7.0](https://github.com/hyperoslo/Spots/tree/5.7.0) (2017-01-02)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.6.1...5.7.0)

**Fixed bugs:**

- SpotsNibDemo or just adding an empty xib to any project crash [\#378](https://github.com/hyperoslo/Spots/issues/378)

**Merged pull requests:**

- Further improve composition [\#400](https://github.com/hyperoslo/Spots/pull/400) ([zenangst](https://github.com/zenangst))
- Improve composition [\#399](https://github.com/hyperoslo/Spots/pull/399) ([zenangst](https://github.com/zenangst))
- Feature universal composition support [\#394](https://github.com/hyperoslo/Spots/pull/394) ([zenangst](https://github.com/zenangst))
- Add amount of items to print statement when using live reloading [\#393](https://github.com/hyperoslo/Spots/pull/393) ([zenangst](https://github.com/zenangst))
- Compare title when diffing Component [\#389](https://github.com/hyperoslo/Spots/pull/389) ([zenangst](https://github.com/zenangst))
- Fix crash in SpotsNibDemo [\#388](https://github.com/hyperoslo/Spots/pull/388) ([aashishdhawan](https://github.com/aashishdhawan))
- Refactor/composition [\#387](https://github.com/hyperoslo/Spots/pull/387) ([zenangst](https://github.com/zenangst))
- Internal/refactoring [\#386](https://github.com/hyperoslo/Spots/pull/386) ([zenangst](https://github.com/zenangst))
- Fix to use a more proper error emoji 😉 [\#385](https://github.com/hyperoslo/Spots/pull/385) ([onmyway133](https://github.com/onmyway133))

## [5.6.1](https://github.com/hyperoslo/Spots/tree/5.6.1) (2016-12-06)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.6.0...5.6.1)

**Merged pull requests:**

- Refactor live editing method [\#384](https://github.com/hyperoslo/Spots/pull/384) ([zenangst](https://github.com/zenangst))

## [5.6.0](https://github.com/hyperoslo/Spots/tree/5.6.0) (2016-12-04)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.5.4...5.6.0)

**Merged pull requests:**

- Add docs to DataSource on macOS [\#383](https://github.com/hyperoslo/Spots/pull/383) ([zenangst](https://github.com/zenangst))
- Improve reload methods [\#382](https://github.com/hyperoslo/Spots/pull/382) ([zenangst](https://github.com/zenangst))
- Improve/spotable mutation [\#381](https://github.com/hyperoslo/Spots/pull/381) ([zenangst](https://github.com/zenangst))
- Move SpotView to macOS folder [\#380](https://github.com/hyperoslo/Spots/pull/380) ([zenangst](https://github.com/zenangst))
- Improve/will display end display [\#379](https://github.com/hyperoslo/Spots/pull/379) ([zenangst](https://github.com/zenangst))
- Feature end display cell [\#377](https://github.com/hyperoslo/Spots/pull/377) ([zenangst](https://github.com/zenangst))
- Add missing completion in reload if needed with items [\#376](https://github.com/hyperoslo/Spots/pull/376) ([zenangst](https://github.com/zenangst))
- Feature will display view on SpotsProtocol [\#375](https://github.com/hyperoslo/Spots/pull/375) ([zenangst](https://github.com/zenangst))
- Refactor reload if needed to update height before calling completion [\#374](https://github.com/hyperoslo/Spots/pull/374) ([zenangst](https://github.com/zenangst))
- Remove/after update on listable [\#373](https://github.com/hyperoslo/Spots/pull/373) ([zenangst](https://github.com/zenangst))

## [5.5.4](https://github.com/hyperoslo/Spots/tree/5.5.4) (2016-11-23)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.5.3...5.5.4)

**Merged pull requests:**

- Improve/mutable spotable objects [\#372](https://github.com/hyperoslo/Spots/pull/372) ([zenangst](https://github.com/zenangst))

## [5.5.3](https://github.com/hyperoslo/Spots/tree/5.5.3) (2016-11-22)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.5.2...5.5.3)

**Merged pull requests:**

- Fix double page control height calculation [\#371](https://github.com/hyperoslo/Spots/pull/371) ([vadymmarkov](https://github.com/vadymmarkov))

## [5.5.2](https://github.com/hyperoslo/Spots/tree/5.5.2) (2016-11-22)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.5.1...5.5.2)

**Merged pull requests:**

- Declare estimatedRowHeight for iOS 8 [\#370](https://github.com/hyperoslo/Spots/pull/370) ([onmyway133](https://github.com/onmyway133))

## [5.5.1](https://github.com/hyperoslo/Spots/tree/5.5.1) (2016-11-22)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.5.0...5.5.1)

**Merged pull requests:**

- Refactor spot height calculations [\#369](https://github.com/hyperoslo/Spots/pull/369) ([zenangst](https://github.com/zenangst))
- Fix CPU spike by constraining Spotable height to parent height [\#368](https://github.com/hyperoslo/Spots/pull/368) ([zenangst](https://github.com/zenangst))

## [5.5.0](https://github.com/hyperoslo/Spots/tree/5.5.0) (2016-11-18)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.4.0...5.5.0)

**Merged pull requests:**

- Improve reload if needed with components [\#367](https://github.com/hyperoslo/Spots/pull/367) ([zenangst](https://github.com/zenangst))
- Fix/xcode project [\#366](https://github.com/hyperoslo/Spots/pull/366) ([zenangst](https://github.com/zenangst))
- Refactor/collection reload section [\#365](https://github.com/hyperoslo/Spots/pull/365) ([zenangst](https://github.com/zenangst))

## [5.4.0](https://github.com/hyperoslo/Spots/tree/5.4.0) (2016-11-17)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.3.1...5.4.0)

**Merged pull requests:**

- Fix layout warnings for carousel [\#364](https://github.com/hyperoslo/Spots/pull/364) ([zenangst](https://github.com/zenangst))
- Fix mutating methods on Listable + improve mutation with proper queuing. [\#363](https://github.com/hyperoslo/Spots/pull/363) ([zenangst](https://github.com/zenangst))
- Rebuild subviewsInLayoutOrder based on subviews layout order. [\#362](https://github.com/hyperoslo/Spots/pull/362) ([zenangst](https://github.com/zenangst))

## [5.3.1](https://github.com/hyperoslo/Spots/tree/5.3.1) (2016-11-16)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.3.0...5.3.1)

**Merged pull requests:**

- Feature remove all on state cache [\#361](https://github.com/hyperoslo/Spots/pull/361) ([zenangst](https://github.com/zenangst))
- Feature spotsDidReloadComponents closure [\#360](https://github.com/hyperoslo/Spots/pull/360) ([zenangst](https://github.com/zenangst))

## [5.3.0](https://github.com/hyperoslo/Spots/tree/5.3.0) (2016-11-14)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.2.0...5.3.0)

**Merged pull requests:**

- Improve/reload with components [\#359](https://github.com/hyperoslo/Spots/pull/359) ([zenangst](https://github.com/zenangst))
- Internal refactoring to reduce code duplication [\#358](https://github.com/hyperoslo/Spots/pull/358) ([zenangst](https://github.com/zenangst))
- Enable SpotableTests [\#357](https://github.com/hyperoslo/Spots/pull/357) ([zenangst](https://github.com/zenangst))

## [5.2.0](https://github.com/hyperoslo/Spots/tree/5.2.0) (2016-11-09)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.1.3...5.2.0)

**Closed issues:**

- Spots demo project fails to compile with Xcode 8.1 [\#350](https://github.com/hyperoslo/Spots/issues/350)
- Improve test coverage [\#279](https://github.com/hyperoslo/Spots/issues/279)

**Merged pull requests:**

- Refactor Delegate and DataSource to use an optional instead of an unwrapped spot [\#354](https://github.com/hyperoslo/Spots/pull/354) ([zenangst](https://github.com/zenangst))
- Feature data & delegate abstraction [\#353](https://github.com/hyperoslo/Spots/pull/353) ([zenangst](https://github.com/zenangst))
- Feature/row spot [\#352](https://github.com/hyperoslo/Spots/pull/352) ([zenangst](https://github.com/zenangst))
- Internal improvements to both iOS and macOS [\#351](https://github.com/hyperoslo/Spots/pull/351) ([zenangst](https://github.com/zenangst))
- Improve mapping [\#349](https://github.com/hyperoslo/Spots/pull/349) ([zenangst](https://github.com/zenangst))

## [5.1.3](https://github.com/hyperoslo/Spots/tree/5.1.3) (2016-11-01)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.1.2...5.1.3)

**Fixed bugs:**

- Fix tvOS compiler errors [\#309](https://github.com/hyperoslo/Spots/issues/309)

**Closed issues:**

- Add generator script for registering Spots [\#288](https://github.com/hyperoslo/Spots/issues/288)

**Merged pull requests:**

- Improve documentation and tests [\#348](https://github.com/hyperoslo/Spots/pull/348) ([zenangst](https://github.com/zenangst))
- Improve/test coverage [\#347](https://github.com/hyperoslo/Spots/pull/347) ([zenangst](https://github.com/zenangst))

## [5.1.2](https://github.com/hyperoslo/Spots/tree/5.1.2) (2016-10-28)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.1.1...5.1.2)

**Merged pull requests:**

- Improve/carousel scroll delegates [\#346](https://github.com/hyperoslo/Spots/pull/346) ([zenangst](https://github.com/zenangst))
- Remove lazy variable and set delegate to nil upon deallocation [\#345](https://github.com/hyperoslo/Spots/pull/345) ([onmyway133](https://github.com/onmyway133))
- Improve/carousel scroll delegates [\#344](https://github.com/hyperoslo/Spots/pull/344) ([vadymmarkov](https://github.com/vadymmarkov))

## [5.1.1](https://github.com/hyperoslo/Spots/tree/5.1.1) (2016-10-26)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.1.0...5.1.1)

**Merged pull requests:**

- Improve/comparing changes [\#343](https://github.com/hyperoslo/Spots/pull/343) ([zenangst](https://github.com/zenangst))

## [5.1.0](https://github.com/hyperoslo/Spots/tree/5.1.0) (2016-10-24)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.0.4...5.1.0)

**Merged pull requests:**

- Improve reload with components [\#342](https://github.com/hyperoslo/Spots/pull/342) ([zenangst](https://github.com/zenangst))
- Refactor Gridable layout [\#341](https://github.com/hyperoslo/Spots/pull/341) ([zenangst](https://github.com/zenangst))
- Fix frame integral [\#340](https://github.com/hyperoslo/Spots/pull/340) ([onmyway133](https://github.com/onmyway133))
- Integral [\#339](https://github.com/hyperoslo/Spots/pull/339) ([Hyperseed](https://github.com/Hyperseed))
- Fix comparison [\#338](https://github.com/hyperoslo/Spots/pull/338) ([Hyperseed](https://github.com/Hyperseed))
- Improve diffing, reduce computation, fix cached views and improve test coverage [\#337](https://github.com/hyperoslo/Spots/pull/337) ([zenangst](https://github.com/zenangst))

## [5.0.4](https://github.com/hyperoslo/Spots/tree/5.0.4) (2016-10-17)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.0.3...5.0.4)

**Merged pull requests:**

- Improve diffing with text property on Item [\#336](https://github.com/hyperoslo/Spots/pull/336) ([zenangst](https://github.com/zenangst))

## [5.0.3](https://github.com/hyperoslo/Spots/tree/5.0.3) (2016-10-14)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.0.2...5.0.3)

**Merged pull requests:**

- Fix/carthage version [\#335](https://github.com/hyperoslo/Spots/pull/335) ([zenangst](https://github.com/zenangst))

## [5.0.2](https://github.com/hyperoslo/Spots/tree/5.0.2) (2016-10-13)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.0.1...5.0.2)

**Merged pull requests:**

- Improve macOS scrolling in CarouselSpot [\#334](https://github.com/hyperoslo/Spots/pull/334) ([zenangst](https://github.com/zenangst))

## [5.0.1](https://github.com/hyperoslo/Spots/tree/5.0.1) (2016-10-13)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/5.0.0...5.0.1)

**Closed issues:**

- Carthage support [\#330](https://github.com/hyperoslo/Spots/issues/330)

**Merged pull requests:**

- Fix height issue in list spot [\#333](https://github.com/hyperoslo/Spots/pull/333) ([zenangst](https://github.com/zenangst))

## [5.0.0](https://github.com/hyperoslo/Spots/tree/5.0.0) (2016-10-13)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/4.0.2...5.0.0)

**Merged pull requests:**

- Remove adapters [\#331](https://github.com/hyperoslo/Spots/pull/331) ([zenangst](https://github.com/zenangst))
- Spots v.5.0.0 in Swift 3 [\#329](https://github.com/hyperoslo/Spots/pull/329) ([zenangst](https://github.com/zenangst))
- Seed the initial size for dummy views [\#328](https://github.com/hyperoslo/Spots/pull/328) ([onmyway133](https://github.com/onmyway133))

## [4.0.2](https://github.com/hyperoslo/Spots/tree/4.0.2) (2016-10-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/4.0.1...4.0.2)

## [4.0.1](https://github.com/hyperoslo/Spots/tree/4.0.1) (2016-10-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/4.0.0...4.0.1)

**Merged pull requests:**

- Fix items [\#327](https://github.com/hyperoslo/Spots/pull/327) ([onmyway133](https://github.com/onmyway133))

## [4.0.0](https://github.com/hyperoslo/Spots/tree/4.0.0) (2016-10-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/3.0.5...4.0.0)

**Closed issues:**

- Handle size change when presenting another view controller [\#313](https://github.com/hyperoslo/Spots/issues/313)

**Merged pull requests:**

- Refactor CollectionAdapter to not call completion twice [\#326](https://github.com/hyperoslo/Spots/pull/326) ([zenangst](https://github.com/zenangst))
- Update README [\#325](https://github.com/hyperoslo/Spots/pull/325) ([zenangst](https://github.com/zenangst))
- Check for dragging and tracking in SpotsScrollView [\#324](https://github.com/hyperoslo/Spots/pull/324) ([zenangst](https://github.com/zenangst))
- Fix dependence of UIScreen [\#323](https://github.com/hyperoslo/Spots/pull/323) ([zenangst](https://github.com/zenangst))
- Check for auto rotation [\#322](https://github.com/hyperoslo/Spots/pull/322) ([onmyway133](https://github.com/onmyway133))
- Add missing docs [\#321](https://github.com/hyperoslo/Spots/pull/321) ([zenangst](https://github.com/zenangst))
- Refactor/spot configurable [\#319](https://github.com/hyperoslo/Spots/pull/319) ([zenangst](https://github.com/zenangst))
- Improve SpotsScrollView layout operations [\#318](https://github.com/hyperoslo/Spots/pull/318) ([zenangst](https://github.com/zenangst))
- Remove force update method on SpotsScrollView [\#317](https://github.com/hyperoslo/Spots/pull/317) ([zenangst](https://github.com/zenangst))
- Add guard if reloading without components [\#316](https://github.com/hyperoslo/Spots/pull/316) ([zenangst](https://github.com/zenangst))
- Fix/reloadifneeded with components [\#315](https://github.com/hyperoslo/Spots/pull/315) ([zenangst](https://github.com/zenangst))

## [3.0.5](https://github.com/hyperoslo/Spots/tree/3.0.5) (2016-09-26)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/3.0.4...3.0.5)

**Closed issues:**

- Remove Sugar as a dependency [\#292](https://github.com/hyperoslo/Spots/issues/292)

**Merged pull requests:**

- Migrate/to new version of brick [\#314](https://github.com/hyperoslo/Spots/pull/314) ([zenangst](https://github.com/zenangst))
- Update/docs [\#312](https://github.com/hyperoslo/Spots/pull/312) ([zenangst](https://github.com/zenangst))

## [3.0.4](https://github.com/hyperoslo/Spots/tree/3.0.4) (2016-09-23)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/3.0.3...3.0.4)

**Merged pull requests:**

- Remove/sugar [\#310](https://github.com/hyperoslo/Spots/pull/310) ([zenangst](https://github.com/zenangst))
- Add separator meta key and setting [\#308](https://github.com/hyperoslo/Spots/pull/308) ([zenangst](https://github.com/zenangst))

## [3.0.3](https://github.com/hyperoslo/Spots/tree/3.0.3) (2016-09-22)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/3.0.2...3.0.3)

**Closed issues:**

- version dependencies in the pod spec files. [\#302](https://github.com/hyperoslo/Spots/issues/302)

## [3.0.2](https://github.com/hyperoslo/Spots/tree/3.0.2) (2016-09-22)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/3.0.1...3.0.2)

## [3.0.1](https://github.com/hyperoslo/Spots/tree/3.0.1) (2016-09-22)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/3.0.0...3.0.1)

## [3.0.0](https://github.com/hyperoslo/Spots/tree/3.0.0) (2016-09-21)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/2.1.2...3.0.0)

**Merged pull requests:**

- Ignore soft updates if animations are set to none [\#307](https://github.com/hyperoslo/Spots/pull/307) ([zenangst](https://github.com/zenangst))
- Improve GridableLayout in horizontal mode [\#306](https://github.com/hyperoslo/Spots/pull/306) ([zenangst](https://github.com/zenangst))
- Feature/dynamic spot height [\#305](https://github.com/hyperoslo/Spots/pull/305) ([vadymmarkov](https://github.com/vadymmarkov))
- Add UI quering methods [\#304](https://github.com/hyperoslo/Spots/pull/304) ([zenangst](https://github.com/zenangst))
- Don't register default items if they are already set in init [\#303](https://github.com/hyperoslo/Spots/pull/303) ([zenangst](https://github.com/zenangst))
- Add computed property to check if cache exists [\#301](https://github.com/hyperoslo/Spots/pull/301) ([zenangst](https://github.com/zenangst))
- Add animations to reloadIfNeeded with Components [\#300](https://github.com/hyperoslo/Spots/pull/300) ([zenangst](https://github.com/zenangst))
- Add return if new items is empty [\#299](https://github.com/hyperoslo/Spots/pull/299) ([zenangst](https://github.com/zenangst))
- Check that index is larger than -1 [\#298](https://github.com/hyperoslo/Spots/pull/298) ([zenangst](https://github.com/zenangst))
- Make SpotCache functions public [\#297](https://github.com/hyperoslo/Spots/pull/297) ([zenangst](https://github.com/zenangst))
- Fix animations for ListAdapter.update [\#296](https://github.com/hyperoslo/Spots/pull/296) ([zenangst](https://github.com/zenangst))
- Fix CollectionAdapter update completion closure not being invoked [\#295](https://github.com/hyperoslo/Spots/pull/295) ([zenangst](https://github.com/zenangst))
- Improve SpotsScrollView with tests [\#294](https://github.com/hyperoslo/Spots/pull/294) ([zenangst](https://github.com/zenangst))
- Remove JSONDictionary and JSONArray references [\#293](https://github.com/hyperoslo/Spots/pull/293) ([zenangst](https://github.com/zenangst))
- Improve tests [\#291](https://github.com/hyperoslo/Spots/pull/291) ([zenangst](https://github.com/zenangst))
- Update docs and minor improvements [\#289](https://github.com/hyperoslo/Spots/pull/289) ([zenangst](https://github.com/zenangst))
- Refactor internal components [\#287](https://github.com/hyperoslo/Spots/pull/287) ([zenangst](https://github.com/zenangst))
- Check for presented view controller [\#286](https://github.com/hyperoslo/Spots/pull/286) ([onmyway133](https://github.com/onmyway133))
- Improve reload if needed code on adapters [\#285](https://github.com/hyperoslo/Spots/pull/285) ([zenangst](https://github.com/zenangst))
- Improve reloadIfNeeded\(components\) [\#284](https://github.com/hyperoslo/Spots/pull/284) ([zenangst](https://github.com/zenangst))
- Refactor process method on SpotsProtocol+Mutation [\#283](https://github.com/hyperoslo/Spots/pull/283) ([zenangst](https://github.com/zenangst))
- Fix/reload bug [\#282](https://github.com/hyperoslo/Spots/pull/282) ([zenangst](https://github.com/zenangst))
- Refactor/file structure [\#281](https://github.com/hyperoslo/Spots/pull/281) ([zenangst](https://github.com/zenangst))
- Feature reloadIfNeeded on Spotable components [\#280](https://github.com/hyperoslo/Spots/pull/280) ([zenangst](https://github.com/zenangst))
- Introduce reloadIfNeeded with components [\#278](https://github.com/hyperoslo/Spots/pull/278) ([zenangst](https://github.com/zenangst))
- Refactor adapters [\#277](https://github.com/hyperoslo/Spots/pull/277) ([zenangst](https://github.com/zenangst))
- Refactor/live editing [\#276](https://github.com/hyperoslo/Spots/pull/276) ([zenangst](https://github.com/zenangst))
- Feature composition and overall header support on iOS [\#275](https://github.com/hyperoslo/Spots/pull/275) ([zenangst](https://github.com/zenangst))
- Set layer frame when updating [\#274](https://github.com/hyperoslo/Spots/pull/274) ([zenangst](https://github.com/zenangst))
- Improve/caching [\#273](https://github.com/hyperoslo/Spots/pull/273) ([zenangst](https://github.com/zenangst))
- Add/ios nib example [\#272](https://github.com/hyperoslo/Spots/pull/272) ([zenangst](https://github.com/zenangst))
- macOS implementation + hard and soft updates for ListSpot [\#271](https://github.com/hyperoslo/Spots/pull/271) ([zenangst](https://github.com/zenangst))
- Fix SpotsFeed and tvOS example [\#270](https://github.com/hyperoslo/Spots/pull/270) ([zenangst](https://github.com/zenangst))
- Fix/spotify iOS demo + SpotCards demo + SpotsDemo [\#269](https://github.com/hyperoslo/Spots/pull/269) ([zenangst](https://github.com/zenangst))
- Fix/apple new demo [\#268](https://github.com/hyperoslo/Spots/pull/268) ([zenangst](https://github.com/zenangst))
- Spots 3.0 - Refactor Spots core and support Nib-files 😈 [\#264](https://github.com/hyperoslo/Spots/pull/264) ([onmyway133](https://github.com/onmyway133))

## [2.1.2](https://github.com/hyperoslo/Spots/tree/2.1.2) (2016-08-11)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/2.1.1...2.1.2)

**Merged pull requests:**

- Don't set current page of the carousel page control [\#267](https://github.com/hyperoslo/Spots/pull/267) ([vadymmarkov](https://github.com/vadymmarkov))

## [2.1.1](https://github.com/hyperoslo/Spots/tree/2.1.1) (2016-08-10)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/2.1.0...2.1.1)

**Closed issues:**

- In Demo "AppleNews" CarouselSpot or GridSpot crashes after scrolling on iPhone6s Plus Device [\#258](https://github.com/hyperoslo/Spots/issues/258)

**Merged pull requests:**

- Refactor layout code in SpotsScrollView [\#266](https://github.com/hyperoslo/Spots/pull/266) ([zenangst](https://github.com/zenangst))
- Move common functions to extension [\#265](https://github.com/hyperoslo/Spots/pull/265) ([zenangst](https://github.com/zenangst))

## [2.1.0](https://github.com/hyperoslo/Spots/tree/2.1.0) (2016-08-09)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/2.0.3...2.1.0)

**Closed issues:**

- UITextField and NSTextField? [\#256](https://github.com/hyperoslo/Spots/issues/256)
- indexes is not used [\#237](https://github.com/hyperoslo/Spots/issues/237)

**Merged pull requests:**

- Improve layout [\#263](https://github.com/hyperoslo/Spots/pull/263) ([zenangst](https://github.com/zenangst))
- Refactor reload and update methods [\#262](https://github.com/hyperoslo/Spots/pull/262) ([zenangst](https://github.com/zenangst))
- Set content size after calling update on ListSpot [\#261](https://github.com/hyperoslo/Spots/pull/261) ([zenangst](https://github.com/zenangst))
- Improve Spots Mac Demo and Mac implementation [\#260](https://github.com/hyperoslo/Spots/pull/260) ([zenangst](https://github.com/zenangst))

## [2.0.3](https://github.com/hyperoslo/Spots/tree/2.0.3) (2016-08-08)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/2.0.2...2.0.3)

**Merged pull requests:**

- Improve: Spotable defaults [\#259](https://github.com/hyperoslo/Spots/pull/259) ([vadymmarkov](https://github.com/vadymmarkov))

## [2.0.2](https://github.com/hyperoslo/Spots/tree/2.0.2) (2016-07-06)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/2.0.1...2.0.2)

**Merged pull requests:**

- Make item with index path safe again [\#257](https://github.com/hyperoslo/Spots/pull/257) ([zenangst](https://github.com/zenangst))

## [2.0.1](https://github.com/hyperoslo/Spots/tree/2.0.1) (2016-07-05)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/2.0.0...2.0.1)

**Closed issues:**

- Make Spots safer [\#238](https://github.com/hyperoslo/Spots/issues/238)

**Merged pull requests:**

- Fix/weird init issue [\#255](https://github.com/hyperoslo/Spots/pull/255) ([zenangst](https://github.com/zenangst))
- Improve/scrollviewDidScroll [\#254](https://github.com/hyperoslo/Spots/pull/254) ([zenangst](https://github.com/zenangst))

## [2.0.0](https://github.com/hyperoslo/Spots/tree/2.0.0) (2016-07-05)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.9.5...2.0.0)

**Implemented enhancements:**

- Feature view model caching [\#199](https://github.com/hyperoslo/Spots/issues/199)

**Merged pull requests:**

- 2.0.0 [\#253](https://github.com/hyperoslo/Spots/pull/253) ([zenangst](https://github.com/zenangst))
- Guard access to item [\#252](https://github.com/hyperoslo/Spots/pull/252) ([onmyway133](https://github.com/onmyway133))
- Change to view.bounds [\#251](https://github.com/hyperoslo/Spots/pull/251) ([onmyway133](https://github.com/onmyway133))
- Avoid accessing view inside lazy block [\#250](https://github.com/hyperoslo/Spots/pull/250) ([onmyway133](https://github.com/onmyway133))
- General foundation changes [\#249](https://github.com/hyperoslo/Spots/pull/249) ([zenangst](https://github.com/zenangst))
- Improve delegate for CarouselSpot [\#248](https://github.com/hyperoslo/Spots/pull/248) ([zenangst](https://github.com/zenangst))

## [1.9.5](https://github.com/hyperoslo/Spots/tree/1.9.5) (2016-06-15)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.9.4...1.9.5)

**Merged pull requests:**

- Minor improvements [\#247](https://github.com/hyperoslo/Spots/pull/247) ([zenangst](https://github.com/zenangst))
- Improve/live editing [\#246](https://github.com/hyperoslo/Spots/pull/246) ([zenangst](https://github.com/zenangst))
- Improve/live editing [\#245](https://github.com/hyperoslo/Spots/pull/245) ([zenangst](https://github.com/zenangst))
- Fix dispatch updates [\#244](https://github.com/hyperoslo/Spots/pull/244) ([zenangst](https://github.com/zenangst))
- Restrict to only run liveEditing in simulator [\#243](https://github.com/hyperoslo/Spots/pull/243) ([zenangst](https://github.com/zenangst))
- Improve/live editing [\#242](https://github.com/hyperoslo/Spots/pull/242) ([zenangst](https://github.com/zenangst))
- Feature live editing mode [\#241](https://github.com/hyperoslo/Spots/pull/241) ([zenangst](https://github.com/zenangst))
- Expose cache and cache load method [\#240](https://github.com/hyperoslo/Spots/pull/240) ([zenangst](https://github.com/zenangst))

## [1.9.4](https://github.com/hyperoslo/Spots/tree/1.9.4) (2016-06-01)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.9.3...1.9.4)

**Implemented enhancements:**

- Improve updating method on SpotsController [\#234](https://github.com/hyperoslo/Spots/pull/234) ([zenangst](https://github.com/zenangst))

**Fixed bugs:**

- Fix scrolling to item when having multiple spots. [\#232](https://github.com/hyperoslo/Spots/pull/232) ([zenangst](https://github.com/zenangst))

**Merged pull requests:**

- Fix layout issue when content size changes [\#239](https://github.com/hyperoslo/Spots/pull/239) ([zenangst](https://github.com/zenangst))
- Improve/update if needed [\#233](https://github.com/hyperoslo/Spots/pull/233) ([zenangst](https://github.com/zenangst))

## [1.9.3](https://github.com/hyperoslo/Spots/tree/1.9.3) (2016-05-20)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.9.2...1.9.3)

**Closed issues:**

- Turn objects into JSON [\#229](https://github.com/hyperoslo/Spots/issues/229)

**Merged pull requests:**

- This remove the case of accessing lazy var in deinit [\#231](https://github.com/hyperoslo/Spots/pull/231) ([onmyway133](https://github.com/onmyway133))

## [1.9.2](https://github.com/hyperoslo/Spots/tree/1.9.2) (2016-05-19)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.9.1...1.9.2)

**Merged pull requests:**

- Improve transition between view controllers [\#230](https://github.com/hyperoslo/Spots/pull/230) ([zenangst](https://github.com/zenangst))
- Use weak self. Nil delegate in deinit [\#228](https://github.com/hyperoslo/Spots/pull/228) ([onmyway133](https://github.com/onmyway133))

## [1.9.1](https://github.com/hyperoslo/Spots/tree/1.9.1) (2016-05-19)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.9.0...1.9.1)

**Closed issues:**

- Please add Cartfile documentation. [\#224](https://github.com/hyperoslo/Spots/issues/224)

**Merged pull requests:**

- Improve scrollTo on SpotsController [\#227](https://github.com/hyperoslo/Spots/pull/227) ([zenangst](https://github.com/zenangst))
- Update README [\#225](https://github.com/hyperoslo/Spots/pull/225) ([zenangst](https://github.com/zenangst))

## [1.9.0](https://github.com/hyperoslo/Spots/tree/1.9.0) (2016-05-12)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.8.4...1.9.0)

**Merged pull requests:**

- Improve Caching for Spotable [\#223](https://github.com/hyperoslo/Spots/pull/223) ([zenangst](https://github.com/zenangst))

## [1.8.4](https://github.com/hyperoslo/Spots/tree/1.8.4) (2016-05-12)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.8.3...1.8.4)

**Merged pull requests:**

- Feature/gridable animation for deletions [\#222](https://github.com/hyperoslo/Spots/pull/222) ([zenangst](https://github.com/zenangst))
- Spots and SpotsDelegate didSet [\#221](https://github.com/hyperoslo/Spots/pull/221) ([onmyway133](https://github.com/onmyway133))
- Fix Spots examples [\#220](https://github.com/hyperoslo/Spots/pull/220) ([onmyway133](https://github.com/onmyway133))

## [1.8.3](https://github.com/hyperoslo/Spots/tree/1.8.3) (2016-05-12)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.8.2...1.8.3)

**Merged pull requests:**

- Fix delete on Gridable [\#219](https://github.com/hyperoslo/Spots/pull/219) ([zenangst](https://github.com/zenangst))

## [1.8.2](https://github.com/hyperoslo/Spots/tree/1.8.2) (2016-05-11)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.8.1...1.8.2)

**Merged pull requests:**

- Improve/build time [\#218](https://github.com/hyperoslo/Spots/pull/218) ([zenangst](https://github.com/zenangst))
- Fix/spots delegate [\#217](https://github.com/hyperoslo/Spots/pull/217) ([onmyway133](https://github.com/onmyway133))

## [1.8.1](https://github.com/hyperoslo/Spots/tree/1.8.1) (2016-05-11)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.8.0...1.8.1)

**Merged pull requests:**

- Allow delegate to be informed of spots change [\#216](https://github.com/hyperoslo/Spots/pull/216) ([onmyway133](https://github.com/onmyway133))

## [1.8.0](https://github.com/hyperoslo/Spots/tree/1.8.0) (2016-05-10)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.7.1...1.8.0)

**Merged pull requests:**

- Don't show header if header height is 0.0 [\#215](https://github.com/hyperoslo/Spots/pull/215) ([vadymmarkov](https://github.com/vadymmarkov))
- Feature: view model cache [\#210](https://github.com/hyperoslo/Spots/pull/210) ([vadymmarkov](https://github.com/vadymmarkov))

## [1.7.1](https://github.com/hyperoslo/Spots/tree/1.7.1) (2016-05-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.7.0...1.7.1)

**Merged pull requests:**

- Fix crash in update method [\#214](https://github.com/hyperoslo/Spots/pull/214) ([zenangst](https://github.com/zenangst))

## [1.7.0](https://github.com/hyperoslo/Spots/tree/1.7.0) (2016-05-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.6.3...1.7.0)

**Merged pull requests:**

- Improve/controling animations [\#213](https://github.com/hyperoslo/Spots/pull/213) ([zenangst](https://github.com/zenangst))
- Improve Componentable headers [\#212](https://github.com/hyperoslo/Spots/pull/212) ([zenangst](https://github.com/zenangst))

## [1.6.3](https://github.com/hyperoslo/Spots/tree/1.6.3) (2016-05-03)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.6.2...1.6.3)

**Merged pull requests:**

- Improve transitioning [\#211](https://github.com/hyperoslo/Spots/pull/211) ([zenangst](https://github.com/zenangst))

## [1.6.2](https://github.com/hyperoslo/Spots/tree/1.6.2) (2016-04-28)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.6.1...1.6.2)

**Merged pull requests:**

- Improve Carousel Spot [\#209](https://github.com/hyperoslo/Spots/pull/209) ([zenangst](https://github.com/zenangst))
- Feature: reload with/without animation [\#208](https://github.com/hyperoslo/Spots/pull/208) ([vadymmarkov](https://github.com/vadymmarkov))
- Make defaultKind a StringConvertible [\#207](https://github.com/hyperoslo/Spots/pull/207) ([zenangst](https://github.com/zenangst))

## [1.6.1](https://github.com/hyperoslo/Spots/tree/1.6.1) (2016-04-26)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.6.0...1.6.1)

**Implemented enhancements:**

- Improve safety when `kind` cannot be resolved into a class [\#205](https://github.com/hyperoslo/Spots/issues/205)

**Fixed bugs:**

- Improve safety when `kind` cannot be resolved into a class [\#205](https://github.com/hyperoslo/Spots/issues/205)

**Merged pull requests:**

- Feature/safe resolving of kinds [\#206](https://github.com/hyperoslo/Spots/pull/206) ([zenangst](https://github.com/zenangst))

## [1.6.0](https://github.com/hyperoslo/Spots/tree/1.6.0) (2016-04-26)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.5.5...1.6.0)

**Merged pull requests:**

- Feature/dictionary on controller and spotable [\#204](https://github.com/hyperoslo/Spots/pull/204) ([zenangst](https://github.com/zenangst))
- Feature .dictionary on Component [\#203](https://github.com/hyperoslo/Spots/pull/203) ([zenangst](https://github.com/zenangst))

## [1.5.5](https://github.com/hyperoslo/Spots/tree/1.5.5) (2016-04-25)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.5.4...1.5.5)

**Merged pull requests:**

- Improve source code documentation [\#202](https://github.com/hyperoslo/Spots/pull/202) ([zenangst](https://github.com/zenangst))

## [1.5.4](https://github.com/hyperoslo/Spots/tree/1.5.4) (2016-04-25)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.5.3...1.5.4)

## [1.5.3](https://github.com/hyperoslo/Spots/tree/1.5.3) (2016-04-25)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.5.2...1.5.3)

**Merged pull requests:**

- Set delegate to spots when in setupSpots [\#201](https://github.com/hyperoslo/Spots/pull/201) ([zenangst](https://github.com/zenangst))

## [1.5.2](https://github.com/hyperoslo/Spots/tree/1.5.2) (2016-04-25)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.5.1...1.5.2)

**Merged pull requests:**

- Add CHANGELOG.md [\#200](https://github.com/hyperoslo/Spots/pull/200) ([zenangst](https://github.com/zenangst))

## [1.5.1](https://github.com/hyperoslo/Spots/tree/1.5.1) (2016-04-25)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.5.0...1.5.1)

**Merged pull requests:**

- Fix/reference [\#198](https://github.com/hyperoslo/Spots/pull/198) ([onmyway133](https://github.com/onmyway133))

## [1.5.0](https://github.com/hyperoslo/Spots/tree/1.5.0) (2016-04-24)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.4.0...1.5.0)

**Merged pull requests:**

- Feature tvOS [\#197](https://github.com/hyperoslo/Spots/pull/197) ([zenangst](https://github.com/zenangst))

## [1.4.0](https://github.com/hyperoslo/Spots/tree/1.4.0) (2016-04-23)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.3.0...1.4.0)

**Merged pull requests:**

- Feature reload with JSON [\#195](https://github.com/hyperoslo/Spots/pull/195) ([zenangst](https://github.com/zenangst))

## [1.3.0](https://github.com/hyperoslo/Spots/tree/1.3.0) (2016-04-23)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.2.1...1.3.0)

**Closed issues:**

- How about carthage support? [\#192](https://github.com/hyperoslo/Spots/issues/192)

**Merged pull requests:**

- Feature carousel page indicator [\#194](https://github.com/hyperoslo/Spots/pull/194) ([zenangst](https://github.com/zenangst))

## [1.2.1](https://github.com/hyperoslo/Spots/tree/1.2.1) (2016-04-22)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.2.0...1.2.1)

**Merged pull requests:**

- Improve collection view sizeForItemAt [\#193](https://github.com/hyperoslo/Spots/pull/193) ([zenangst](https://github.com/zenangst))

## [1.2.0](https://github.com/hyperoslo/Spots/tree/1.2.0) (2016-04-21)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.1.4...1.2.0)

**Closed issues:**

- Build failed for both cartfile and podspec [\#185](https://github.com/hyperoslo/Spots/issues/185)

**Merged pull requests:**

- Improve: reload if needed [\#191](https://github.com/hyperoslo/Spots/pull/191) ([vadymmarkov](https://github.com/vadymmarkov))
- Update playground [\#190](https://github.com/hyperoslo/Spots/pull/190) ([zenangst](https://github.com/zenangst))

## [1.1.4](https://github.com/hyperoslo/Spots/tree/1.1.4) (2016-04-19)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.1.3...1.1.4)

**Merged pull requests:**

- Improve list spot [\#189](https://github.com/hyperoslo/Spots/pull/189) ([zenangst](https://github.com/zenangst))
- Add a Gitter chat badge to README.md [\#188](https://github.com/hyperoslo/Spots/pull/188) ([gitter-badger](https://github.com/gitter-badger))

## [1.1.3](https://github.com/hyperoslo/Spots/tree/1.1.3) (2016-04-18)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.1.2...1.1.3)

**Merged pull requests:**

- Refactor Spotable implementation [\#186](https://github.com/hyperoslo/Spots/pull/186) ([zenangst](https://github.com/zenangst))

## [1.1.2](https://github.com/hyperoslo/Spots/tree/1.1.2) (2016-04-18)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.1.1...1.1.2)

**Closed issues:**

- When OSX version will be created? [\#184](https://github.com/hyperoslo/Spots/issues/184)

**Merged pull requests:**

- Refactor internal protocols [\#183](https://github.com/hyperoslo/Spots/pull/183) ([zenangst](https://github.com/zenangst))

## [1.1.1](https://github.com/hyperoslo/Spots/tree/1.1.1) (2016-04-15)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.1.0...1.1.1)

**Merged pull requests:**

- Document source code and update README [\#182](https://github.com/hyperoslo/Spots/pull/182) ([zenangst](https://github.com/zenangst))
- Refresh indexes on reload [\#181](https://github.com/hyperoslo/Spots/pull/181) ([vadymmarkov](https://github.com/vadymmarkov))

## [1.1.0](https://github.com/hyperoslo/Spots/tree/1.1.0) (2016-04-14)
[Full Changelog](https://github.com/hyperoslo/Spots/compare/1.0.0...1.1.0)

**Closed issues:**

- I have an error when install Spots with Cartfile [\#178](https://github.com/hyperoslo/Spots/issues/178)

**Merged pull requests:**

- Feature documentation for SpotsController, Listable and Gridable [\#180](https://github.com/hyperoslo/Spots/pull/180) ([zenangst](https://github.com/zenangst))
- Feature: custom table view + view registry [\#179](https://github.com/hyperoslo/Spots/pull/179) ([vadymmarkov](https://github.com/vadymmarkov))

## [1.0.0](https://github.com/hyperoslo/Spots/tree/1.0.0) (2016-04-12)
**Closed issues:**

- Expose scrollViewDidScroll? [\#161](https://github.com/hyperoslo/Spots/issues/161)
- Spots and Imaginary pods missing [\#157](https://github.com/hyperoslo/Spots/issues/157)
- Use of unresolved identifier 'ListItem' in Spotify example [\#146](https://github.com/hyperoslo/Spots/issues/146)
- Add Travis [\#67](https://github.com/hyperoslo/Spots/issues/67)
- Internal component naming [\#24](https://github.com/hyperoslo/Spots/issues/24)

**Merged pull requests:**

- Set cell height in prepareItem [\#176](https://github.com/hyperoslo/Spots/pull/176) ([vadymmarkov](https://github.com/vadymmarkov))
- Add fallback to cell size if view model height is 0 [\#175](https://github.com/hyperoslo/Spots/pull/175) ([zenangst](https://github.com/zenangst))
- Update Brick version [\#174](https://github.com/hyperoslo/Spots/pull/174) ([zenangst](https://github.com/zenangst))
- Fix completion bug in Gridable component [\#173](https://github.com/hyperoslo/Spots/pull/173) ([zenangst](https://github.com/zenangst))
- Feature Brick [\#172](https://github.com/hyperoslo/Spots/pull/172) ([zenangst](https://github.com/zenangst))
- Improve comparing view models [\#171](https://github.com/hyperoslo/Spots/pull/171) ([zenangst](https://github.com/zenangst))
- Allow more configuration on the cell [\#170](https://github.com/hyperoslo/Spots/pull/170) ([onmyway133](https://github.com/onmyway133))
- Refactor Spotify demo [\#169](https://github.com/hyperoslo/Spots/pull/169) ([zenangst](https://github.com/zenangst))
- Add some syntax sugar to the implementation [\#168](https://github.com/hyperoslo/Spots/pull/168) ([zenangst](https://github.com/zenangst))
- Use new frame based sugar and fix conflict with height in UIView [\#167](https://github.com/hyperoslo/Spots/pull/167) ([zenangst](https://github.com/zenangst))
- Remove all references and dependencies on Imaginary [\#166](https://github.com/hyperoslo/Spots/pull/166) ([zenangst](https://github.com/zenangst))
- Remove class names from selectors [\#165](https://github.com/hyperoslo/Spots/pull/165) ([zenangst](https://github.com/zenangst))
- Migrate to Swift 2.2 [\#164](https://github.com/hyperoslo/Spots/pull/164) ([zenangst](https://github.com/zenangst))
- Spring cleaning of implementation [\#163](https://github.com/hyperoslo/Spots/pull/163) ([zenangst](https://github.com/zenangst))
- Feature Apple news for you detail view [\#162](https://github.com/hyperoslo/Spots/pull/162) ([zenangst](https://github.com/zenangst))
- Call forceUpdate in viewDidAppear [\#160](https://github.com/hyperoslo/Spots/pull/160) ([zenangst](https://github.com/zenangst))
- Force update after mutating data source [\#159](https://github.com/hyperoslo/Spots/pull/159) ([zenangst](https://github.com/zenangst))
- Check if index is in bound of relations array [\#158](https://github.com/hyperoslo/Spots/pull/158) ([onmyway133](https://github.com/onmyway133))
- Implement completion for spots reload [\#156](https://github.com/hyperoslo/Spots/pull/156) ([vadymmarkov](https://github.com/vadymmarkov))
- Add update index method on SpotsController [\#155](https://github.com/hyperoslo/Spots/pull/155) ([zenangst](https://github.com/zenangst))
- Check for span [\#154](https://github.com/hyperoslo/Spots/pull/154) ([onmyway133](https://github.com/onmyway133))
- Set minimumLineSpacing for GridSpot [\#153](https://github.com/hyperoslo/Spots/pull/153) ([zenangst](https://github.com/zenangst))
- Restrict Gridable from modifying view model width if span is zero [\#152](https://github.com/hyperoslo/Spots/pull/152) ([zenangst](https://github.com/zenangst))
- Use new version of Hue [\#151](https://github.com/hyperoslo/Spots/pull/151) ([zenangst](https://github.com/zenangst))
- Improve For You controller in Apple News demo [\#150](https://github.com/hyperoslo/Spots/pull/150) ([zenangst](https://github.com/zenangst))
- Migrate to new version of Tailor [\#149](https://github.com/hyperoslo/Spots/pull/149) ([zenangst](https://github.com/zenangst))
- Overall improvements [\#148](https://github.com/hyperoslo/Spots/pull/148) ([zenangst](https://github.com/zenangst))
- Fix Spotify demo [\#147](https://github.com/hyperoslo/Spots/pull/147) ([zenangst](https://github.com/zenangst))
- Fix/spot feed demo [\#145](https://github.com/hyperoslo/Spots/pull/145) ([zenangst](https://github.com/zenangst))
- Revert swapping view with scrollView [\#144](https://github.com/hyperoslo/Spots/pull/144) ([zenangst](https://github.com/zenangst))
- Improve relation mapping via JSON [\#143](https://github.com/hyperoslo/Spots/pull/143) ([zenangst](https://github.com/zenangst))
- Minor changes to SpotsController [\#142](https://github.com/hyperoslo/Spots/pull/142) ([zenangst](https://github.com/zenangst))
- Add scrollToBottom on SpotsController [\#141](https://github.com/hyperoslo/Spots/pull/141) ([zenangst](https://github.com/zenangst))
- Feature/meta functions [\#140](https://github.com/hyperoslo/Spots/pull/140) ([vadymmarkov](https://github.com/vadymmarkov))
- Feature view model relation [\#139](https://github.com/hyperoslo/Spots/pull/139) ([zenangst](https://github.com/zenangst))
- Rename Itemble and ListItem [\#138](https://github.com/hyperoslo/Spots/pull/138) ([zenangst](https://github.com/zenangst))
- Improve public API methods for manipulating data [\#137](https://github.com/hyperoslo/Spots/pull/137) ([zenangst](https://github.com/zenangst))
- Add refresh control if spotsRefreshDelegate is set [\#136](https://github.com/hyperoslo/Spots/pull/136) ([zenangst](https://github.com/zenangst))
- Refactor refresh control [\#134](https://github.com/hyperoslo/Spots/pull/134) ([zenangst](https://github.com/zenangst))
- Add custom content inset for SpotsScrollView [\#133](https://github.com/hyperoslo/Spots/pull/133) ([zenangst](https://github.com/zenangst))
- Fix refresh control [\#132](https://github.com/hyperoslo/Spots/pull/132) ([vadymmarkov](https://github.com/vadymmarkov))
- Only trigger infinite scrolling if delegate is set [\#131](https://github.com/hyperoslo/Spots/pull/131) ([zenangst](https://github.com/zenangst))
- Fix delete in Listable [\#130](https://github.com/hyperoslo/Spots/pull/130) ([vadymmarkov](https://github.com/vadymmarkov))
- Fix bug when trying to append new item to Listable objects [\#129](https://github.com/hyperoslo/Spots/pull/129) ([zenangst](https://github.com/zenangst))
- Improve reloading ListItems in Listable [\#128](https://github.com/hyperoslo/Spots/pull/128) ([zenangst](https://github.com/zenangst))
- Perform updates with animations in Listable [\#127](https://github.com/hyperoslo/Spots/pull/127) ([zenangst](https://github.com/zenangst))
- Revert "Fix append on Listable and Gridable" [\#126](https://github.com/hyperoslo/Spots/pull/126) ([zenangst](https://github.com/zenangst))
- Fix append on Listable and Gridable [\#125](https://github.com/hyperoslo/Spots/pull/125) ([zenangst](https://github.com/zenangst))
- Refactor cached objects in prepareSpot [\#124](https://github.com/hyperoslo/Spots/pull/124) ([zenangst](https://github.com/zenangst))
- Add caching when preparing Spots [\#123](https://github.com/hyperoslo/Spots/pull/123) ([zenangst](https://github.com/zenangst))
- Feature view spot [\#122](https://github.com/hyperoslo/Spots/pull/122) ([zenangst](https://github.com/zenangst))
- Refactor internals [\#121](https://github.com/hyperoslo/Spots/pull/121) ([zenangst](https://github.com/zenangst))
- Update README.md [\#120](https://github.com/hyperoslo/Spots/pull/120) ([zenangst](https://github.com/zenangst))
- Add iOS Playground [\#119](https://github.com/hyperoslo/Spots/pull/119) ([zenangst](https://github.com/zenangst))
- Add GridSpotSpec and ListSpotSpec [\#118](https://github.com/hyperoslo/Spots/pull/118) ([zenangst](https://github.com/zenangst))
- Enable code coverage [\#117](https://github.com/hyperoslo/Spots/pull/117) ([zenangst](https://github.com/zenangst))
- Refactor/framework target [\#116](https://github.com/hyperoslo/Spots/pull/116) ([vadymmarkov](https://github.com/vadymmarkov))
- Update all examples [\#114](https://github.com/hyperoslo/Spots/pull/114) ([zenangst](https://github.com/zenangst))
- Feature new cover image [\#113](https://github.com/hyperoslo/Spots/pull/113) ([zenangst](https://github.com/zenangst))
- Feature init with JSON [\#112](https://github.com/hyperoslo/Spots/pull/112) ([zenangst](https://github.com/zenangst))
- Rename Components to Spots in CONTRIBUTING. [\#111](https://github.com/hyperoslo/Spots/pull/111) ([frodsan](https://github.com/frodsan))
- Update Apole News demo [\#110](https://github.com/hyperoslo/Spots/pull/110) ([zenangst](https://github.com/zenangst))
- Fix infinite scrolling [\#109](https://github.com/hyperoslo/Spots/pull/109) ([zenangst](https://github.com/zenangst))
- Update README [\#108](https://github.com/hyperoslo/Spots/pull/108) ([zenangst](https://github.com/zenangst))
- Add super.viewDidAppear\(animated\) [\#107](https://github.com/hyperoslo/Spots/pull/107) ([zenangst](https://github.com/zenangst))
- Feature Spotify Example [\#106](https://github.com/hyperoslo/Spots/pull/106) ([zenangst](https://github.com/zenangst))
- Remove return from update closure [\#105](https://github.com/hyperoslo/Spots/pull/105) ([zenangst](https://github.com/zenangst))
- Improve/public api [\#104](https://github.com/hyperoslo/Spots/pull/104) ([zenangst](https://github.com/zenangst))
- Improve public API [\#103](https://github.com/hyperoslo/Spots/pull/103) ([zenangst](https://github.com/zenangst))
- Feature/spotify example tab bar [\#102](https://github.com/hyperoslo/Spots/pull/102) ([vadymmarkov](https://github.com/vadymmarkov))
- Add UIKit and Foundation as dependencies [\#101](https://github.com/hyperoslo/Spots/pull/101) ([vadymmarkov](https://github.com/vadymmarkov))
- Remove refreshable label in init [\#100](https://github.com/hyperoslo/Spots/pull/100) ([zenangst](https://github.com/zenangst))
- Improve updating spots [\#99](https://github.com/hyperoslo/Spots/pull/99) ([zenangst](https://github.com/zenangst))
- Feature: spots refresh delegate [\#98](https://github.com/hyperoslo/Spots/pull/98) ([vadymmarkov](https://github.com/vadymmarkov))
- Refactor/spots scroll view [\#97](https://github.com/hyperoslo/Spots/pull/97) ([zenangst](https://github.com/zenangst))
- Fix faulty boolean value in infinite scrolling [\#96](https://github.com/hyperoslo/Spots/pull/96) ([zenangst](https://github.com/zenangst))
- Fix/infinite scrolling [\#95](https://github.com/hyperoslo/Spots/pull/95) ([zenangst](https://github.com/zenangst))
- Rename spotDelegate to spotsDelegate [\#94](https://github.com/hyperoslo/Spots/pull/94) ([zenangst](https://github.com/zenangst))
- Feature: spots scroll delegate [\#93](https://github.com/hyperoslo/Spots/pull/93) ([vadymmarkov](https://github.com/vadymmarkov))
- Refactor voodoo black magic [\#92](https://github.com/hyperoslo/Spots/pull/92) ([zenangst](https://github.com/zenangst))
- Fix jumpyness in infinte scrolling [\#91](https://github.com/hyperoslo/Spots/pull/91) ([zenangst](https://github.com/zenangst))
- Rename SpotContentView and SpotScrollView [\#90](https://github.com/hyperoslo/Spots/pull/90) ([zenangst](https://github.com/zenangst))
- Get along with Xcode 7.1.1 [\#89](https://github.com/hyperoslo/Spots/pull/89) ([zenangst](https://github.com/zenangst))
- Improve refreshing SpotController [\#88](https://github.com/hyperoslo/Spots/pull/88) ([zenangst](https://github.com/zenangst))
- Update spotsDelegate on all spots when setting spotDelegate to SpotsController [\#87](https://github.com/hyperoslo/Spots/pull/87) ([zenangst](https://github.com/zenangst))
- Feature: spot configuration [\#86](https://github.com/hyperoslo/Spots/pull/86) ([vadymmarkov](https://github.com/vadymmarkov))
- Organize code and move scroll methods to extension [\#85](https://github.com/hyperoslo/Spots/pull/85) ([zenangst](https://github.com/zenangst))
- Improve sizing of the container in viewWillAppear [\#84](https://github.com/hyperoslo/Spots/pull/84) ([zenangst](https://github.com/zenangst))
- Fix/refresh control [\#83](https://github.com/hyperoslo/Spots/pull/83) ([zenangst](https://github.com/zenangst))
- Simplify refresh control implementation [\#82](https://github.com/hyperoslo/Spots/pull/82) ([zenangst](https://github.com/zenangst))
- Improve refreshing spots controller [\#81](https://github.com/hyperoslo/Spots/pull/81) ([zenangst](https://github.com/zenangst))
- Feature: imaginary [\#80](https://github.com/hyperoslo/Spots/pull/80) ([vadymmarkov](https://github.com/vadymmarkov))
- Experimental/refactor/spots controller [\#79](https://github.com/hyperoslo/Spots/pull/79) ([zenangst](https://github.com/zenangst))
- Improve refresh control [\#78](https://github.com/hyperoslo/Spots/pull/78) ([zenangst](https://github.com/zenangst))
- Remove infix operators [\#77](https://github.com/hyperoslo/Spots/pull/77) ([zenangst](https://github.com/zenangst))
- Feature spot search [\#76](https://github.com/hyperoslo/Spots/pull/76) ([zenangst](https://github.com/zenangst))
- Feature/infix operator on component [\#75](https://github.com/hyperoslo/Spots/pull/75) ([zenangst](https://github.com/zenangst))
- Refactor inset logic to support "all" scenarios [\#74](https://github.com/hyperoslo/Spots/pull/74) ([zenangst](https://github.com/zenangst))
- Feature/convenience properties [\#73](https://github.com/hyperoslo/Spots/pull/73) ([zenangst](https://github.com/zenangst))
- Feature/headers in feed spot [\#72](https://github.com/hyperoslo/Spots/pull/72) ([zenangst](https://github.com/zenangst))
- Use tabBarController instead of resolving parentViewController [\#71](https://github.com/hyperoslo/Spots/pull/71) ([zenangst](https://github.com/zenangst))
- Improve Foundation and Apple News demo [\#70](https://github.com/hyperoslo/Spots/pull/70) ([zenangst](https://github.com/zenangst))
- Improve general setup [\#69](https://github.com/hyperoslo/Spots/pull/69) ([zenangst](https://github.com/zenangst))
- Remove legacy code on delegate [\#68](https://github.com/hyperoslo/Spots/pull/68) ([zenangst](https://github.com/zenangst))
- Feature/spo factory test patch [\#66](https://github.com/hyperoslo/Spots/pull/66) ([zenangst](https://github.com/zenangst))
- Feature: spot factory test [\#65](https://github.com/hyperoslo/Spots/pull/65) ([vadymmarkov](https://github.com/vadymmarkov))
- Improve overall safety [\#64](https://github.com/hyperoslo/Spots/pull/64) ([zenangst](https://github.com/zenangst))
- Refactor Examples to use Spots in podfile [\#63](https://github.com/hyperoslo/Spots/pull/63) ([zenangst](https://github.com/zenangst))
- Feature Component and ListItem tests [\#62](https://github.com/hyperoslo/Spots/pull/62) ([zenangst](https://github.com/zenangst))
- Feature/example update script [\#61](https://github.com/hyperoslo/Spots/pull/61) ([zenangst](https://github.com/zenangst))
- Default to component kind if items lacks kind [\#60](https://github.com/hyperoslo/Spots/pull/60) ([zenangst](https://github.com/zenangst))
- Improve prepareSpot [\#59](https://github.com/hyperoslo/Spots/pull/59) ([zenangst](https://github.com/zenangst))
- Register with component kind if items is empty [\#58](https://github.com/hyperoslo/Spots/pull/58) ([zenangst](https://github.com/zenangst))
- Update to new version of Sugar [\#57](https://github.com/hyperoslo/Spots/pull/57) ([zenangst](https://github.com/zenangst))
- Refactor setup method [\#56](https://github.com/hyperoslo/Spots/pull/56) ([zenangst](https://github.com/zenangst))
- Always add refresh control for FeedSpots [\#55](https://github.com/hyperoslo/Spots/pull/55) ([zenangst](https://github.com/zenangst))
- Refactor Spots spot - Mainly FeedSpot [\#54](https://github.com/hyperoslo/Spots/pull/54) ([zenangst](https://github.com/zenangst))
- Refactor Spots Controller [\#53](https://github.com/hyperoslo/Spots/pull/53) ([zenangst](https://github.com/zenangst))
- Feature protocol extensions [\#52](https://github.com/hyperoslo/Spots/pull/52) ([zenangst](https://github.com/zenangst))
- General improvements to public interface [\#51](https://github.com/hyperoslo/Spots/pull/51) ([zenangst](https://github.com/zenangst))
- Dispatch all updates in main queue [\#50](https://github.com/hyperoslo/Spots/pull/50) ([zenangst](https://github.com/zenangst))
- Configure cached headers [\#49](https://github.com/hyperoslo/Spots/pull/49) ([zenangst](https://github.com/zenangst))
- Feature header height [\#48](https://github.com/hyperoslo/Spots/pull/48) ([zenangst](https://github.com/zenangst))
- Feature: spot view configuration closure [\#47](https://github.com/hyperoslo/Spots/pull/47) ([vadymmarkov](https://github.com/vadymmarkov))
- Update reload methods [\#46](https://github.com/hyperoslo/Spots/pull/46) ([zenangst](https://github.com/zenangst))
- Feature default cell setup [\#45](https://github.com/hyperoslo/Spots/pull/45) ([zenangst](https://github.com/zenangst))
- Set image if available [\#44](https://github.com/hyperoslo/Spots/pull/44) ([zenangst](https://github.com/zenangst))
- Feature refreshable spots [\#43](https://github.com/hyperoslo/Spots/pull/43) ([zenangst](https://github.com/zenangst))
- Feature Spot manipulation [\#42](https://github.com/hyperoslo/Spots/pull/42) ([zenangst](https://github.com/zenangst))
- Refactor list spot [\#41](https://github.com/hyperoslo/Spots/pull/41) ([zenangst](https://github.com/zenangst))
- Make protocols public [\#40](https://github.com/hyperoslo/Spots/pull/40) ([zenangst](https://github.com/zenangst))
- Refactor setting list spot cell height [\#39](https://github.com/hyperoslo/Spots/pull/39) ([zenangst](https://github.com/zenangst))
- Improve list spot cell height [\#38](https://github.com/hyperoslo/Spots/pull/38) ([zenangst](https://github.com/zenangst))
- Add framework logo [\#37](https://github.com/hyperoslo/Spots/pull/37) ([zenangst](https://github.com/zenangst))
- Feature logo [\#36](https://github.com/hyperoslo/Spots/pull/36) ([zenangst](https://github.com/zenangst))
- Improve feed demo [\#35](https://github.com/hyperoslo/Spots/pull/35) ([zenangst](https://github.com/zenangst))
- Feature using Spots programmatically [\#34](https://github.com/hyperoslo/Spots/pull/34) ([zenangst](https://github.com/zenangst))
- Refactor cards demo + remove pages and map spot [\#33](https://github.com/hyperoslo/Spots/pull/33) ([zenangst](https://github.com/zenangst))
- Feature card demo [\#32](https://github.com/hyperoslo/Spots/pull/32) ([zenangst](https://github.com/zenangst))
- Feature feed demo [\#31](https://github.com/hyperoslo/Spots/pull/31) ([zenangst](https://github.com/zenangst))
- Feature map spot [\#30](https://github.com/hyperoslo/Spots/pull/30) ([zenangst](https://github.com/zenangst))
- Improve Carousel and cell initialisation [\#29](https://github.com/hyperoslo/Spots/pull/29) ([zenangst](https://github.com/zenangst))
- Improve base demo [\#28](https://github.com/hyperoslo/Spots/pull/28) ([zenangst](https://github.com/zenangst))
- Improve basic layout and fix warnings [\#27](https://github.com/hyperoslo/Spots/pull/27) ([zenangst](https://github.com/zenangst))
- Feature/page spot [\#26](https://github.com/hyperoslo/Spots/pull/26) ([vadymmarkov](https://github.com/vadymmarkov))
- Improve demo [\#25](https://github.com/hyperoslo/Spots/pull/25) ([zenangst](https://github.com/zenangst))
- Improve/customization [\#23](https://github.com/hyperoslo/Spots/pull/23) ([zenangst](https://github.com/zenangst))
- Spot factory [\#22](https://github.com/hyperoslo/Spots/pull/22) ([vadymmarkov](https://github.com/vadymmarkov))
- Refactor/parser [\#21](https://github.com/hyperoslo/Spots/pull/21) ([zenangst](https://github.com/zenangst))
- Feature/carousel [\#20](https://github.com/hyperoslo/Spots/pull/20) ([zenangst](https://github.com/zenangst))
- Fix/rotation layout [\#19](https://github.com/hyperoslo/Spots/pull/19) ([zenangst](https://github.com/zenangst))
- Rename the rest to be Spots [\#18](https://github.com/hyperoslo/Spots/pull/18) ([zenangst](https://github.com/zenangst))
- Feature/spots [\#17](https://github.com/hyperoslo/Spots/pull/17) ([vadymmarkov](https://github.com/vadymmarkov))
- Feature Grid span [\#16](https://github.com/hyperoslo/Spots/pull/16) ([zenangst](https://github.com/zenangst))
- Custom cells feature [\#15](https://github.com/hyperoslo/Spots/pull/15) ([vadymmarkov](https://github.com/vadymmarkov))
- Improve list component cell [\#14](https://github.com/hyperoslo/Spots/pull/14) ([zenangst](https://github.com/zenangst))
- Feature Grid component [\#13](https://github.com/hyperoslo/Spots/pull/13) ([zenangst](https://github.com/zenangst))
- Refactor model structure [\#12](https://github.com/hyperoslo/Spots/pull/12) ([zenangst](https://github.com/zenangst))
- Add dynamic sizing to base collection view [\#11](https://github.com/hyperoslo/Spots/pull/11) ([zenangst](https://github.com/zenangst))
- Add more dummy data [\#10](https://github.com/hyperoslo/Spots/pull/10) ([zenangst](https://github.com/zenangst))
- Feature dynamic list height [\#9](https://github.com/hyperoslo/Spots/pull/9) ([zenangst](https://github.com/zenangst))
- Add title to list component [\#8](https://github.com/hyperoslo/Spots/pull/8) ([zenangst](https://github.com/zenangst))
- Revert ComponentView renaming [\#7](https://github.com/hyperoslo/Spots/pull/7) ([zenangst](https://github.com/zenangst))
- Improve object declarations in Parser [\#6](https://github.com/hyperoslo/Spots/pull/6) ([zenangst](https://github.com/zenangst))
- Move reuseIdentifier into static string [\#5](https://github.com/hyperoslo/Spots/pull/5) ([zenangst](https://github.com/zenangst))
- Improve Xcode project [\#4](https://github.com/hyperoslo/Spots/pull/4) ([zenangst](https://github.com/zenangst))
- Rename Component to ComponentView [\#3](https://github.com/hyperoslo/Spots/pull/3) ([zenangst](https://github.com/zenangst))
- Feature object mapping during parsing [\#2](https://github.com/hyperoslo/Spots/pull/2) ([zenangst](https://github.com/zenangst))
- Setup CocoaPods [\#1](https://github.com/hyperoslo/Spots/pull/1) ([zenangst](https://github.com/zenangst))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*