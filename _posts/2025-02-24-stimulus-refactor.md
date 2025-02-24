---
layout: post
title: Stimulus refactor
date: 2025-02-24
category: stimulus
slug: stimulus-refactor
---

## Context

stimulus separates data processing in three components: 
- split (into train/validation/test)
- transform (modifications to raw data - downsampling for example)
- encode (raw data to pytorch tensors)

Some key observations considering the input data (example adapted from [kaggle](https://www.kaggle.com/datasets/yasserh/titanic-dataset){:target="_blank"}): 

| passenger_id | survived | pclass | sex    | age  | sibsp | parch | fare     | embarked |
|---------------|----------|--------|--------|------|-------|-------|----------|----------|
| 1             | 0        | 3      | male   | 22.0 | 1     | 0     | 7.25     | S        |
| 2             | 1        | 1      | female | 38.0 | 1     | 0     | 71.2833  | C        |
| 3             | 1        | 3      | female | 26.0 | 0     | 0     | 7.925    | S        |
| 4             | 1        | 1      | female | 35.0 | 1     | 0     | 53.1     | S        |



- Split needs to be called on a specific (group of) column(s).
- Column types vary, thus transforms are column-specific.
- Likewise for encoding.
- Columns serve different purposes:
    - input (e.g., `age`)
    - target (`survived`)
    - meta-data (`passenger_id`)

Since stimulus is thought to be a command line tool first, these bits and pieces are defined in an external .yaml configuration file. 
For encoders, it looks like this: 

```yaml
columns:
  - column_name: fare 
    column_type: input
    data_type: float
    encoder:
      - name: NumericEncoder
        params:
```

Here, we are defining that `fare` is an input column, and need to be encoded using [NumericEncoder](https://mathysgrapotte.github.io/stimulus-py/reference/stimulus/data/encoding/encoders/#stimulus.data.encoding.encoders.NumericEncoder){:target="_blank"}

We do the same for transforms: 
```yaml
transforms:
  - transformation_name: noise
    columns:
      - column_name: age
        transformations:
          - name: GaussianNoise
            params:
              std: [0.1, 0.2, 0.3]
      - column_name: fare
        transformations:
          - name: GaussianNoise
            params:
              std: [0.1, 0.2, 0.3]
```

Here we apply [GaussianNoise](https://mathysgrapotte.github.io/stimulus-py/reference/stimulus/data/transform/data_transformation_generators/#stimulus.data.transform.data_transformation_generators.GaussianNoise){:target="_blank"} to two different columns with three different standard deviation parameters.

and we define the split parameters as such : 
```yaml
split:
  - split_method: RandomSplit
    split_input_columns: [age]
    params:
      split: [0.7, 0.15, 0.15]
```

We use a [RandomSplit](https://mathysgrapotte.github.io/stimulus-py/reference/stimulus/data/splitters/#stimulus.data.splitters.RandomSplit){:target="_blank"} splitter on the `age` column, separating the data into 70% for training, 15% for validation and 15% for testing.

## Interfacing configuration files with the data, the old way

The configuration file serves as an interface between the data and the code, for this to happen correctly, we need to:

- General
    1. understand which columns are input, meta-data or target(label).
- Encoders
    1. link the encoder with its column.
    2. fetch the proper encoder from the codebase.
    3. use the right encoder on the right column when considering the full dataset, taking care of input, meta-data or target considerations.
- Transforms
    1. link transforms with their columns.
    2. fetch the proper transforms from the codebase.
    3. remember the order of transforms within a group (e.g. the `noise` group defined above).
    4. use the right transform group on the right columns when considering the full dataset.
- Split
    1. fetch the proper splitter from the codebase.
    2. use it on the right column or set of columns.

Until now, we dealt with the problem by providing three levels of abstractions. 

1. Loaders, [for example, EncoderLoader](https://mathysgrapotte.github.io/stimulus-py/reference/stimulus/data/loaders/#stimulus.data.loaders.EncoderLoader){:target="_blank"} includes boilerplate code to load from the configuration file, fetch the proper encoder from the codebase and get its `encode_all` method. 
2. Managers, [for example, EncodeManager](https://mathysgrapotte.github.io/stimulus-py/reference/stimulus/data/data_handlers/#stimulus.data.data_handlers.EncodeManager), holds the logic of which encoder to use on which column and boilerplate code to apply encoders to a subset of the dataframe. 
3. Finally, the [dataset handler](https://mathysgrapotte.github.io/stimulus-py/reference/stimulus/data/data_handlers/#stimulus.data.data_handlers.DatasetHandler) main class, split into `DatasetLoader` and `DatasetProcessor`, contains boilerplate code to load the data from disk, apply transformations and split, and feed the data to the network as a dictionary of PyTorch tensors.


If you would need to visualize it, would look like this:

<div style="width: 60vw; margin-left: calc(-27vw + 50%); margin-right: calc(-25vw + 50%); text-align: center;">
<img src="https://mermaid.ink/svg/pako:eNptlOFrnDAYxv8VSb-mrF57PerKYMyDGxg2UAab9sM7E0-pJpLoh9Hr_75oEk-twoF53-eX5PHJ5Q3lgjIUoLOEtvSSMOOeflT_1xQiAZRJZarDc4zSIx8YaVov3u3tl0vBGFUX70iuwiRKEwlcFUI2G9JkJo2jNG7rqtuQxVbGOM34am8EOJwXmwtJGkIHinW2Z-bKBS-q88ULTzMfxPpYKNlY0uuGZi8zO-RqZ4F0rjpQP6XImVJiBsbEmFtAaqhsAFs2v3_6MXN4cg5PwGnt5qt4yeTmjAZai9burpSbfiq8PGvWu7RmPH4brZihZi7HbWRI9CetP_j7NoaS_v5KIvs-QjpD249_pfo3rmY7Nr6Q2FTrvuGeC9edPdudYpkEyVIwRjA1h3Nm2nkNSoWs8OrRiVdUdR3c-LAvDoBVJ8UrC27uYJff088rojERW-TpYf_gP03Io3__6N-tkdKkaJEd3cPuMCE-aOQwR_TfDycRjiO7u0WL4ITgmGBt0O5k3g5P-Joytqm59RFGDZMNVFRfBW8DlqGuZA3LUKBfKcjXDGX8Xeug70T8j-co6GTPMJKiP5du0LcUOhZWoI9u44ot8D9C6GEBtdJjRqtOSGLunfH6ef8P-8t0hA">
</div>

This outlines two main problems:
1. Three levels of abstraction, the codebase is too hard to understand.
2. Tight coupling between the various classes, if you change one module, everything breaks.

point 1. is fairly easy to understand by looking at the above diagram, so let's discuss point 2.

point 2. is best understood by looking at the current [TorchDataset class](https://mathysgrapotte.github.io/stimulus-py/reference/stimulus/data/handlertorch/#stimulus.data.handlertorch.TorchDataset){:target="_blank"} which interfaces the data with the neural network.

```python
class TorchDataset(torch.utils.data.Dataset):
    """Class for creating a torch dataset."""

    def __init__(
        self,
        config_path: str,
        csv_path: str,
        encoder_loader: loaders.EncoderLoader,
        split: Optional[int] = None,
    ) -> None:
        """Initialize the TorchDataset.

        Args:
            config_path: Path to the configuration file
            csv_path: Path to the CSV data file
            encoder_loader: Encoder loader instance
            split: Optional tuple containing split information
        """
        self.loader = data_handlers.DatasetLoader(
            config_path=config_path,
            csv_path=csv_path,
            encoder_loader=encoder_loader,
            split=split,
        )

    def __len__(self) -> int:
        return len(self.loader)

    def __getitem__(self, idx: int) -> tuple[dict, dict, dict]:
        return self.loader[idx]
```
This function, which should be simple in its implementation, will perform lots of things under the hood: 
- load the data from disk using the proper split (train/validation/test) if needed
- load the configuration file defined above
- make sure encoder loader fits
- return the data in a format that can be used by the neural network

If any of those steps is changed somewhere else in the code (for instance, `DatasetLoader` config path argument is renamed), TorchDataset will break. Every little change requires hours of debugging. 

Since scientific code requires to be extremely flexible (to try the new cool things), we want to minimize the time it takes to implement a change in the codebase.

## Interfacing configuration files with the data, the new way

The first idea here is to remove as many abstractions as possible. `Encoders`, `Transforms`, and `Splitters` are non-compressible core functionalities, same goes with `DatasetHandler` classes.

Focusing on native python data structures (such as dictionaries, lists, etc.) will make the codebase readable (our contributors understand dictionaries, not necessarly `DatasetManagers`). 

Think about it in this way: the more concepts contributors need to learn, the more likely they will quit before the first PR.

For this, we need to rethink the way we do I/O management in between our elements. Config parsing has to be outsourced to a dedicated module, which shall output simple, native python objects. `DatasetHandler` classes will expect those objects as input, and will not do the parsing themselves (one class should do one thing):

```python
class DatasetLoader(DatasetHandler):
    """Class for loading dataset and passing it to the deep learning model."""

    def __init__(
        self,
        encoders: dict[str, encoders_module.AbstractEncoder],
        input_columns: list[str],
        label_columns: list[str],
        meta_columns: list[str],
        csv_path: str,
        split: Optional[int] = None,
    ) -> None:
    ...
```

Here, instead of having loaders and managers, we load needed information directly to the `DatasetHandler` class, in simple, native python objects. For example, the class itself is not expected to find out which columns are input, labels or meta-data; this was done beforehand. 

Notice as well, that the encoders are expected in a simple dictionary of format `{column_name: encoder_instance}`. When needing to find an encoder for a specific column, we only need to access the dictionary with the name of the column that we want to encode as the key. 

This allows us to completely decouple the `DatasetHandler` class from the configuration file parsing. If the configuration file format changes, DatasetHandler does not care about it (as it always expects objects to be already parsed), which addresses point 2!

To further explain how we decouple the codebase, lets rewrite the `TorchDataset` class:

```python
class TorchDataset(torch.utils.data.Dataset):
    """Class for creating a torch dataset."""

    def __init__(
        self,
        loader: DatasetLoader, 
        # loader is initialized outside of TorchDataset
    ) -> None:
        """Initialize the TorchDataset.

        Args:
            loader: A DatasetLoader instance
        """
        self.loader = loader

    def __len__(self) -> int:
        return len(self.loader)

    def __getitem__(self, idx: int) -> tuple[dict, dict, dict]:
        return self.loader[idx]
```

Here, as long as `DatasetLoader` implements the `__getitem__` and `__len__` methods, TorchDataset will work. Changing the inner working of `DatasetLoader` will not affect `TorchDataset`! 

Altogether, those changes make the codebase intuitive, and the data flows streamlined, if we rebuild the class diagram, it would look like this:

<div style="width: 40vw; margin-left: calc(-20vw + 50%); margin-right: calc(-25vw + 50%); text-align: center;">
<img src="https://mermaid.ink/svg/pako:eNp1kk2PwiAQhv8KwWtNrJ-xu9mL3cSLiUmNh7V7mC1gGykQoIeN-t-Xlqq1GznBzPPOF3PGmSQUR_ioQeVoF6cCuWOqH29YScGK4xa0odq76rPaHrwDec83Gg4_Lqq-mwv6FHVMbbr8E7DTIAyTunyNJIoX9h6DCpKKXmUxWDDUrkEQ3q0tXh-eXb646kVp8bpxg3IJX9XWZ56La4n3GuESiANWyf6fmlFauzYuP__XVcbBmJgy1PSvESs4jwYhzNgCAmO1PNFoMIJxNiFvPUXuu2wlYzKD8eIuCWEyDxd9CXHzafnldDYNl3d-Hjp-1OXrj1Gd7_dG11PeHXyLJvvgNuHgMcjgNq8mMQ5wSXUJBXFbd67lKbY5LWmKI3cloE8pTsXVcVBZmfyKDEdWVzTAWlbH_PaolItG4wLcOpQ4YsCNsyoQX1I-3pQUVuqN3_Fm1a9_Io_x4Q">
</div>

Way better right ? 

You can follow the refactoring effort on the [project board](https://github.com/users/mathysgrapotte/projects/2){:target="_blank"}.