---
description: This page introduces the to-be-continuous community.
---

# Community

Need help? Any enhancement or bug to suggest? Want to contribute?<br/>
[Join the community](https://discord.gg/SetvpZ9XZ6)!

## Check out our code

You can [see code on GitLab](https://gitlab.com/to-be-continuous).

## Any question?

* [ask on Stack Overflow](https://stackoverflow.com/questions/tagged/to-be-continuous)
* [ask on Discord](https://discord.com/channels/917018885088215060/1099343975695011991)

## Want to contribute?

We try to make it easy, and all contributions, even the smallest ones, are more than welcome.
This includes bug reports, fixes, documentation, examples...

First, read our [contribution guide](dev/workflow.md).
Then, remember to announce your intention on [the dedicated channel](https://discord.com/channels/917018885088215060/1099353913418850374).

## Share!

Remember _to be continuous_ is a totally free and open-source project. 
If you like it, please say it!

* add a star ⭐ to every template project you're using (on [gitlab.com](https://gitlab.com/to-be-continuous)) -- that will promote the project in the CI/CD catalog
* please share your feedback in the [⭐-i-use-tbc](https://discord.com/channels/917018885088215060/1203686227761565728) channel


Consider this as our rewarding.
Thanks in advance 🙏 

> [!tip] To star all TBC templates all at once
> ```BASH
> curl -sSf "https://gitlab.com/api/v4/groups/to-be-continuous/projects?per_page=100" | jq -r '.[].id' | while read pid; do curl -X POST -H "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/$pid/star"; done
> ```
>
> :bulb: requires `curl` & `jq`

## Let's Talk!

Like any free and open-source project, _to be continuous_ thrives on community engagement. Your feedback, discussions, and shared experiences help it grow and evolve.

Have you given a presentation or hosted a discussion about _to be continuous_? Feel free to share links to your public presentations here!

### Capitole du libre, 2022

Pierre Smeyers showcased _to be continuous_ at [Capitole du Libre](https://capitoledulibre.org/) in November 2022 in Toulouse.

Recordings:

* [Youtube](https://www.youtube.com/watch?v=LOWnPgWXXjU)
* [Vidéos Capitole du Libre](https://videos.capitoledulibre.org/w/192KBaj5z32RYungghqCop)

### Open Source Experience, 2023

Girija Saint-Ange and Guilhem Bonnefille presented _to be continuous_ at [Open Source Experience](https://www.opensource-experience.com/) in December 2023, held in Paris.

No recordings are available for this session.
