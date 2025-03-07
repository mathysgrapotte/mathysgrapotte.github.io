---
layout: post
title: Unifying Data and Models
date: 2025-03-07
category: stimulus
slug: stimulus-intro
---

We became explorers of the hyper-parameter space. 

At first glance, hyper-parameters teached about the nature of the model; how does learning rate impact convergence speed? Should models be deeper ? 

The further one wander in this space, the more one realizes that hyper-parmaeters questions our assumptions about the data. If my deeper model learns better, what does it say about the complexity of the data? 

This realization flurished into questions: 
- How do hyper-parameters evolve when data changes?
- Does this help us understand the nature of the data?
- ...
- What if, the goal all along was the hyper-parameters themselves? Equations teach us about the world; more so than their outputs.

One thing is clear to me; a model in a vacuum, without its training data, is incomplete. Like an answer to an unknown question or the output of an hidden equation. 

For this reason, we have built stimulus: a way to fuse data processing and model training in a single, unified, pipeline. 

### Data processing hyper-space

Data processing define their own hyper-parameter space. Should images be rotated? how should the text be tokenized? 

As data distances itself from our understanding of the world, processing parametrisation increases in complexity. Which mapper should I use for my sequencing data? Which quality filter? how should I do peak calling? What would my background signal be?

We found that most data processing, regardless of complexity, fall into three atomic steps: 
1. split
2. transform
3. encode

Split defines which subset of the data trains, and which subset of the data validates the model performance. If splitting is done right, it should carefully assess the ability of the model to generalize to unseen examples. I would even argue, that splitting, should let us understand **which unseen examples** the model is able to generalize to. 

Transformations define how the data is modified in its raw form. Peak-callers, data cleaning, down/up-sampling, etc. fall into this category. At this stage, the data is still human readable. 

Encode describes the final step. At this point, data converts into gpu-readable language. Most underestimate this step, although at this stage, data often undergoes the most drastic changes.

For this reason, stimulus provides a way to define an exploration space for each of these steps. You will find mentions of splitters, encoders and transformers littered accross the documentation and the tool, it is essential that those basic building blocks are configurable and explorable.

Ultimately; model parameters, processing parameters, and performance analytics paint a whole picture describing the data, it is a question alongside its answer, provided you know which question to ask.

