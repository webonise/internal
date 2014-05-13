Webonise Skype Index
========================

Skype has become the de facto standard communication tool at Webonise. It works great in a lot of ways, but there are two notable pain points:
# When a new person comes on board, everyone needs to get access to their information.
# Pulling together a multi-part call is a hassle, especially once you get up to a half dozen people or so.
#+ (One solution for this is to [create a grouping in your favorites](http://blogs.skype.com/2013/05/09/7-tips-for-a-great-group-chat-on-skype/).)

This file is a place for everyone to drop their Skype information and to construct common call lists in order to ease that pain.

Data
------

Data is stored into two places: `users.yaml` and `calls.yaml`.  
The `users.yaml` file is where you put Skype user contact information.
The `calls.yaml` file is where you put call information.
See the samples and comments within those files for details.

View
-----

The view file is `index.haml`, and that's HAML. HAML is a thin but powerful layer on top of HTML, and it is compiled down to HTML. For the cost of that compilation
step, you get the ability to use a more human-accessible syntax and whatever Ruby extensions you'd like.
For more information on HAML and its awesomeness, see [the HAML homepage](http://haml.info/). 

*View Generation*

The short form is that you can install HAML using:

```bash
gem install haml
```

Then generate the HTML from HAML using:

```bash
haml index.haml index.html
```

Then please commit both the HAML and the HTML back to GitHub.
