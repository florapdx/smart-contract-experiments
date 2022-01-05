# Micro audit
# For Theo's project: https://github.com/Optilistic/crowdfundr-example/blob/master/contracts/Crowdfundr.sol

Definitely learned some things while reading through this - for example, I didn't know require() could take a second param error message! 

## issue-1
** Code Quality: doesn't conform to spec

On line 26: constructor takes `_daysToExpiration` and puts an upper limit at 90, however the spec says projects have a 30-day window.
On line 61: comment says 30 days, though, so maybe this was changed at some point and not updated.

## issue-2
** Code Quality: more of a design/UX question, really!

Lines 47 + 62: 
What's the advantage of having the owner or users "lock" a project instead of automating that at the time of contribution?

Given that there's no eventing around goal met or time expired, how would the owner or users know when to call these functions -- wouldn't it cost them gas to find out? Is the only way currently for them to pull a list of all projects down and iterate to find the project they're interested in to view the status? 

In the owner case, they'll have to pay at least 2x -- once to call the `lockOwner` method, then at least one other time to withdraw funds.

In the contributor case, if more than one contributor calls the `lockContributor` message, each n+1 contributor will get the `isUnlocked` error message `the project is currently locked`, but they won't have the reason so won't know if they should call `withdrawContributor` or not (don't they lose gas for the `success` lookup? Or no?)

## nits (questions, really - I don't know enought to nit!)

* On line 30, locked declared `false`, but already initialized to false (default value) - is there a reason for that? Like, because that var is used in modifiers, is it better to set explicitly (and then is there some reason to do that in the constructor vs at declaration?)

* I'm confused about why the project instance on line 120 is returned (a) and wrapped in `payable` (b) -- what does returning mean here and what does wrapping a contract instance in `payable` do?

* related question: what's the advantage of using the `fallback` method instead of a custom named method for receiving contributions? I tried to read about this online, but just became more confused.

